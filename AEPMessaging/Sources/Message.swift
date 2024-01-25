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
import Foundation
import WebKit

/// Class that contains the definition of an in-app message and controls its tracking via Experience Edge events.
@objc(AEPMessage)
public class Message: NSObject {
    // MARK: - public properties

    /// ID of the `Message`.
    @objc public var id: String

    /// If set to `true` (default), Experience Edge events will automatically be generated when this `Message` is
    /// triggered, displayed, and dismissed.
    @objc public var autoTrack: Bool = true

    /// Points to the message's `WKWebView` instance, if it exists.
    @objc public var view: UIView? {
        fullscreenMessage?.webView
    }

    // MARK: internal properties

    /// Holds a reference to the class that created this `Message`.  Used for access to tracking code owned by `Messaging`.
    weak var parent: Messaging?

    /// A `FullscreenMessage` generated by the SDK's shared UI services.
    var fullscreenMessage: FullscreenMessage?

    /// A map of assets used by the message, and a path to their cached location in the local file system.
    var assets: [String: String]?

    /// The `Event` that triggered this `Message`.  Primarily used for getting the correct `Configuration` for
    /// access to the AEP Dataset ID.
    var triggeringEvent: Event

    /// Holds XDM data necessary for tracking `Message` interactions with Adobe Journey Optimizer.
    var propositionInfo: PropositionInfo?

    init(parent: Messaging, triggeringEvent: Event) {
        id = ""
        self.parent = parent
        self.triggeringEvent = triggeringEvent
        super.init()
    }

    // MARK: - UI management

    /// Requests that UIServices show the this message.
    /// This method will bypass calling the `shouldShowMessage(:)` method of the `MessagingDelegate` if one exists.
    /// If `autoTrack` is true and the message is shown, calling this method will result
    /// in an "inapp.display" Edge Event being dispatched.
    @objc
    public func show() {
        show(withMessagingDelegateControl: false)
    }

    /// Signals to the UIServices that the message should be dismissed.
    /// If `autoTrack` is true, calling this method will result in an "inapp.dismiss" Edge Event being dispatched.
    /// - Parameter suppressAutoTrack: if set to `true`, the "inapp.dismiss" Edge Event will not be sent regardless
    ///   of the `autoTrack` setting.
    @objc(dismissSuppressingAutoTrack:)
    public func dismiss(suppressAutoTrack: Bool = false) {
        if autoTrack, !suppressAutoTrack {
            track(nil, withEdgeEventType: .dismiss)
        }

        fullscreenMessage?.dismiss()
    }

    // MARK: - Edge Event creation

    /// Generates an Edge Event for the provided `interaction` and `eventType`.
    ///
    /// - Parameters:
    ///   - interaction: a custom `String` value to be recorded in the interaction
    ///   - eventType: the `MessagingEdgeEventType` to be used for the ensuing Edge Event
    @objc(trackInteraction:withEdgeEventType:)
    public func track(_ interaction: String?, withEdgeEventType eventType: MessagingEdgeEventType) {
        guard let propInfo = propositionInfo else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Unable to send a proposition interaction, proposition info is not found for message (\(id)).")
            return
        }

        let propositionInteractionXdm = MessagingPropositionInteraction(eventType: eventType, interaction: interaction ?? "", propositionInfo: propInfo, itemId: nil).xdm
        parent?.sendPropositionInteraction(withXdm: propositionInteractionXdm)
    }

    // MARK: - WebView javascript handling

    /// Adds a handler for Javascript messages sent from the message's webview.
    ///
    /// The parameter passed to `handler` will contain the body of the message passed from the webview's Javascript.
    ///
    /// - Parameters:
    ///   - name: the name of the message that should be handled by `handler`
    ///   - handler: the closure to be called with the body of the message passed by the Javascript message
    @objc(handleJavascriptMessage:withHandler:)
    public func handleJavascriptMessage(_ name: String, withHandler handler: @escaping (Any?) -> Void) {
        fullscreenMessage?.handleJavascriptMessage(name, withHandler: handler)
    }

    // MARK: - Internal methods

    /// Requests that UIServices show the this message.
    /// Pass `false` to this method to bypass the `MessagingDelegate` control over showing the message.
    /// - Parameters:
    ///   - withMessagingDelegateControl: if `true`, the `shouldShowMessage(:)` method of `MessagingDelegate` will be called before the message is shown.
    func show(withMessagingDelegateControl callDelegate: Bool) {
        fullscreenMessage?.show(withMessagingDelegateControl: callDelegate)
    }

    /// Called when a `Message` is triggered - i.e. it's conditional criteria have been met.
    func trigger() {
        if autoTrack {
            track(nil, withEdgeEventType: .trigger)
        }
        recordEventHistory(eventType: .trigger, interaction: nil)
    }

    /// Dispatches an event to be recorded in Event History.
    ///
    /// Record is created using the `propositionInfo.activityId` for this message.
    ///
    /// - Parameters:
    ///  - eventType: `MessagingEdgeEventType` to be recorded
    ///  - interaction: if provided, adds a custom interaction to the hash
    func recordEventHistory(eventType: MessagingEdgeEventType, interaction: String?) {
        guard let propInfo = propositionInfo else {
            Log.debug(label: MessagingConstants.LOG_TAG, "Unable to write event history event '\(eventType.propositionEventType)', proposition info is not available for message (\(id)).")
            return
        }

        // iam dictionary used for event history
        let iamHistory: [String: String] = [
            MessagingConstants.Event.History.Keys.EVENT_TYPE: eventType.propositionEventType,
            MessagingConstants.Event.History.Keys.MESSAGE_ID: propInfo.activityId,
            MessagingConstants.Event.History.Keys.TRACKING_ACTION: interaction ?? ""
        ]

        // wrap history in an "iam" object
        let eventHistoryData: [String: Any] = [
            MessagingConstants.Event.Data.Key.IAM_HISTORY: iamHistory
        ]

        let mask = [
            MessagingConstants.Event.History.Mask.EVENT_TYPE,
            MessagingConstants.Event.History.Mask.MESSAGE_ID,
            MessagingConstants.Event.History.Mask.TRACKING_ACTION
        ]

        let interactionLog = interaction == nil ? "" : " with value '\(interaction ?? "")'"
        Log.trace(label: MessagingConstants.LOG_TAG, "Writing '\(eventType.propositionEventType)' event\(interactionLog) to EventHistory for in-app message with activityId '\(propInfo.activityId)'")

        let event = Event(name: MessagingConstants.Event.Name.EVENT_HISTORY_WRITE,
                          type: EventType.messaging,
                          source: MessagingConstants.Event.Source.EVENT_HISTORY_WRITE,
                          data: eventHistoryData,
                          mask: mask)
        parent?.runtime.dispatch(event: event)
    }

    // MARK: - Private methods

    /// Generates a mapping of the message's assets to their representation in local cache.
    ///
    /// This method will iterate through the provided `newAssets`.
    /// In each iteration, it will check to see if there is a corresponding cache entry for the
    /// asset string.  If a match is found, an entry will be made in the `Message`s `assets` dictionary.
    ///
    /// - Parameter newAssets: optional array of asset urls represented as strings
    /// - Returns: `true` if an asset map was generated
    private func generateAssetMap(_ newAssets: [String]?) -> Bool {
        guard let remoteAssetsArray = newAssets, !remoteAssetsArray.isEmpty else {
            return false
        }

        let cache = Cache(name: MessagingConstants.Caches.CACHE_NAME)
        assets = [:]
        for asset in remoteAssetsArray {
            // check for a matching file in cache and add an entry to the assets map if it exists
            if let cachedAsset = cache.get(key: asset) {
                assets?[asset] = cachedAsset.metadata?[MessagingConstants.Caches.PATH]
            }
        }

        return true
    }
}

extension Message {
    static func fromPropositionItem(_ propositionItem: MessagingPropositionItem, with parent: Messaging, triggeringEvent event: Event) -> Message? {
        guard let iamSchemaData = propositionItem.inappSchemaData,
              let htmlContent = iamSchemaData.content as? String
        else {
            return nil
        }

        let message = Message(parent: parent, triggeringEvent: event)
        message.id = propositionItem.itemId
        let messageSettings = iamSchemaData.getMessageSettings(with: message)
        let usingLocalAssets = message.generateAssetMap(iamSchemaData.remoteAssets)
        message.fullscreenMessage = ServiceProvider.shared.uiService.createFullscreenMessage?(payload: htmlContent,
                                                                                              listener: message,
                                                                                              isLocalImageUsed: usingLocalAssets,
                                                                                              settings: messageSettings) as? FullscreenMessage
        if usingLocalAssets {
            message.fullscreenMessage?.setAssetMap(message.assets)
        }

        return message
    }
}
