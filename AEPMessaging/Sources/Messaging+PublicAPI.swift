/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
import AEPServices
import UserNotifications

@objc public extension Messaging {
    

    /// Sends the push notification interactions as an experience event to Adobe Experience Edge.
    /// - Parameters:
    ///   - response: UNNotificationResponse object which contains the payload and xdm informations.
    ///   - applicationOpened: Boolean values denoting whether the application was opened when notification was clicked
    ///   - customActionId: String value of the custom action (e.g button id on the notification) which was clicked.
    @objc(handleNotificationResponse:applicationOpened:withCustomActionId:)
    static func handleNotificationResponse(_ response: UNNotificationResponse, applicationOpened: Bool, customActionId: String?) {
        let notificationRequest = response.notification.request
        let xdm = notificationRequest.content.userInfo[MessagingConstants.AdobeTrackingKeys._XDM] as? [String: Any]
        // Checking if the message has xdm key
        if xdm == nil {
            Log.warning(label: MessagingConstants.LOG_TAG, "Failed to track push notification interaction. XDM specific fields are missing.")
        }

        let messageId = notificationRequest.identifier
        if messageId.isEmpty {
            Log.warning(label: MessagingConstants.LOG_TAG, "Failed to track push notification interaction, Message Id is invalid in the response.")
            return
        }

        // Creating event data with tracking informations
        var eventData: [String: Any] = [MessagingConstants.EventDataKeys.MESSAGE_ID: messageId,
                                        MessagingConstants.EventDataKeys.APPLICATION_OPENED: applicationOpened,
                                        MessagingConstants.EventDataKeys.ADOBE_XDM: xdm ?? [:]] // If xdm data is nil we use empty dictionary
        if customActionId == nil {
            eventData[MessagingConstants.EventDataKeys.EVENT_TYPE] = MessagingConstants.EventDataValue.PUSH_TRACKING_APPLICATION_OPENED
        } else {
            eventData[MessagingConstants.EventDataKeys.EVENT_TYPE] = MessagingConstants.EventDataValue.PUSH_TRACKING_CUSTOM_ACTION
            eventData[MessagingConstants.EventDataKeys.ACTION_ID] = customActionId
        }

        let event = Event(name: MessagingConstants.EventName.PUSH_NOTIFICATION_INTERACTION,
                          type: MessagingConstants.EventType.messaging,
                          source: EventSource.requestContent,
                          data: eventData)
        MobileCore.dispatch(event: event)
    }
    
    static func handleReceiveRemoteNotification(withUserInfo userInfo: [AnyHashable : Any]) {
        self.internalHandleReceiveRemoteNotification(withUserInfo: userInfo)
    }
    
    static func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) -> Bool {
        return internaldidReceive(request, withContentHandler: contentHandler)
    }
    
    static func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension Messaging {
    
    static func internalHandleReceiveRemoteNotification(withUserInfo userInfo: [AnyHashable : Any]) {
        guard let aps = userInfo["aps"] as? Dictionary<String, Any> else {
            return
        }
        
        guard let deletionMessageId = aps["deleteMessageExecutionID"] as? String else {
            return
        }
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getDeliveredNotifications { deliveredNotifications in
            for eachNotification in deliveredNotifications {
                if let xdm = eachNotification.request.content.userInfo["_xdm"] as? Dictionary<String, Any> {
                    if let mixin = xdm["mixin"] as? Dictionary<String, Any> {
                        if let experience = mixin["_experience"] as? Dictionary<String, Any> {
                            if let customerJourneyManagement = experience["customerJourneyManagement"] as? Dictionary<String, Any> {
                                if let messageExecutionID = customerJourneyManagement["messageExecution"] as? String {
                                    if messageExecutionID == deletionMessageId {
                                        notificationCenter.removeDeliveredNotifications(withIdentifiers: [eachNotification.request.identifier])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func internaldidReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) -> Bool {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            return false
        }
        guard let imageURLString =
                bestAttemptContent.userInfo["adb_media"] as? String else {
            contentHandler(bestAttemptContent)
            return false
        }
        
        getMediaAttachment(for: imageURLString) { image in
            // 3
            guard
                let image = image,
                let fileURL = saveImageAttachment(
                    image: image,
                    forIdentifier: "attachment.png")
            else {
                contentHandler(bestAttemptContent)
                return
            }

            // 5
            let imageAttachment = try? UNNotificationAttachment(
                identifier: "image",
                url: fileURL,
                options: nil)

            // 6
            if let imageAttachment = imageAttachment {
                bestAttemptContent.attachments = [imageAttachment]
            }
            contentHandler(bestAttemptContent)
        }
        return true
    }
    
    private static func getMediaAttachment(for urlString: String, completion: @escaping (UIImage?) -> Void) {
      // 1
      guard let url = URL(string: urlString) else {
        completion(nil)
        return
      }

      // 2
      downloadImage(forURL: url) { result in
        // 3
        guard let image = try? result.get() else {
          completion(nil)
          return
        }

        // 4
        completion(image)
      }
    }
    
    private static func saveImageAttachment(image: UIImage, forIdentifier identifier: String) -> URL? {
      // 1
      let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
      // 2
      let directoryPath = tempDirectory.appendingPathComponent(
        ProcessInfo.processInfo.globallyUniqueString,
        isDirectory: true)

      do {
        // 3
        try FileManager.default.createDirectory(
          at: directoryPath,
          withIntermediateDirectories: true,
          attributes: nil)

        // 4
        let fileURL = directoryPath.appendingPathComponent(identifier)

        // 5
        guard let imageData = image.pngData() else {
          return nil
        }

        // 6
        try imageData.write(to: fileURL)
          return fileURL
        } catch {
          return nil
      }
    }

    private static func downloadImage(forURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
          completion(.failure(error))
          return
        }
        
        guard let data = data else {
          completion(.failure(DownloadError.emptyData))
          return
        }
        
        guard let image = UIImage(data: data) else {
          completion(.failure(DownloadError.invalidImage))
          return
        }
        
        completion(.success(image))
      }
      
      task.resume()
    }
}

enum DownloadError: Error {
  case emptyData
  case invalidImage
}
