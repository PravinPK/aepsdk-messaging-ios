/*
 Copyright 2023 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation
@testable import AEPCore
@testable import AEPMessaging
import AEPEdgeIdentity
import XCTest

class MessagingNotificationTrackingTests: FunctionalTestBase {
    
    static let mockUserInfo = ["_xdm" :
                                ["cjm":
                                    ["_experience":
                                        ["customerJourneyManagement":
                                            ["messageExecution":
                                                ["messageExecutionID": "mockExecutionID",
                                                 "journeyVersionID": "mockJourneyVersionID",
                                                 "journeyVersionInstanceId": "mockJourneyVersionInstanceId",
                                                 "messageID": "mockMessageId"]
                                            ]
                                        ]
                                    ]
                                ]
    ]
    
    
    public class override func setUp() {
        super.setUp()
        FunctionalTestBase.debugEnabled = true
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        FileManager.default.clearCache()

        // hub shared state update for 1 extension versions (InstrumentedExtension (registered in FunctionalTestBase), IdentityEdge, Edge Identity, Config
        setExpectationEvent(type: EventType.hub, source: EventSource.sharedState, expectedCount: 3)
        

        // expectations for update config request&response events
        setExpectationEvent(type: EventType.configuration, source: EventSource.requestContent, expectedCount: 1)
        setExpectationEvent(type: EventType.configuration, source: EventSource.responseContent, expectedCount: 1)
        setExpectationEvent(type: EventType.edge, source: EventSource.requestContent, expectedCount: 1)
        
        // wait for async registration because the EventHub is already started in FunctionalTestBase
        let waitForRegistration = CountDownLatch(1)
        MobileCore.registerExtensions([Messaging.self, Identity.self], {
            print("Extensions registration is complete")
            waitForRegistration.countDown()
        })
        XCTAssertEqual(DispatchTimeoutResult.success, waitForRegistration.await(timeout: 2))
        MobileCore.updateConfigurationWith(configDict: ["messaging.eventDataset": "mockDataset"])

        assertExpectedEvents(ignoreUnexpectedEvents: false)
        resetTestExpectations()
        setNotificationCategories()
    }
    
    // MARK: - Tests
    
    func test_notificationTracking_whenUser_tapsNotificationBody() {
        // setup
        setExpectationEvent(type: EventType.edge, source: EventSource.requestContent, expectedCount: 1)
        let response = prepareNotificationResponse()!
        
        // test
        Messaging.handleNotificationResponse(response)
        
        // verify
        let events = getDispatchedEventsWith(type: EventType.edge, source: EventSource.requestContent)
        XCTAssertEqual(1, events.count)
        let edgeEvent = events.first!
        let flattenEdgeEvent = edgeEvent.data?.flattening()
        
        // verify push tracking information
        XCTAssertEqual(1, flattenEdgeEvent?["xdm.application.launches.value"] as? Int)
        XCTAssertEqual("pushTracking.applicationOpened", flattenEdgeEvent?["xdm.eventType"] as? String)
        XCTAssertNil(flattenEdgeEvent?["xdm.pushNotificationTracking.customAction.actionID"] as? String)
        
        // verify cjm/mixins and other xdm related data
        XCTAssertEqual("mockJourneyVersionID", flattenEdgeEvent?["xdm._experience.customerJourneyManagement.messageExecution.journeyVersionID"] as? String)
        XCTAssertEqual("mockJourneyVersionInstanceId", flattenEdgeEvent?["xdm._experience.customerJourneyManagement.messageExecution.journeyVersionInstanceId"] as? String)
        XCTAssertEqual("mockMessageId", flattenEdgeEvent?["xdm._experience.customerJourneyManagement.messageExecution.messageID"] as? String)
        XCTAssertEqual("apns", flattenEdgeEvent?["xdm._experience.customerJourneyManagement.pushChannelContext.platform"] as? String)
        XCTAssertEqual("https://ns.adobe.com/xdm/channels/push", flattenEdgeEvent?["xdm._experience.customerJourneyManagement.messageProfile.channel._id"] as? String)
        XCTAssertEqual("mockExecutionID", flattenEdgeEvent?["xdm._experience.customerJourneyManagement.messageExecution.messageExecutionID"] as? String)
        
        XCTAssertEqual("apns", flattenEdgeEvent?["xdm.pushNotificationTracking.pushProvider"] as? String)
        XCTAssertEqual("messageId", flattenEdgeEvent?["xdm.pushNotificationTracking.pushProviderMessageID"] as? String)
        XCTAssertEqual("mockDataset", flattenEdgeEvent?["meta.collect.datasetId"] as? String)
    }
    
    func test_notificationTracking_whenUser_DismissesNotification() {
        // setup
        setExpectationEvent(type: EventType.edge, source: EventSource.requestContent, expectedCount: 1)
        let response = prepareNotificationResponse(actionIdentifier: UNNotificationDismissActionIdentifier)!
        
        // test
        Messaging.handleNotificationResponse(response)
        
        // verify
        let events = getDispatchedEventsWith(type: EventType.edge, source: EventSource.requestContent)
        XCTAssertEqual(1, events.count)
        let edgeEvent = events.first!
        let flattenEdgeEvent = edgeEvent.data?.flattening()
        
        // verify push tracking information
        XCTAssertEqual(0, flattenEdgeEvent?["xdm.application.launches.value"] as? Int)
        XCTAssertEqual("pushTracking.customAction", flattenEdgeEvent?["xdm.eventType"] as? String)
        XCTAssertEqual("Dismiss",flattenEdgeEvent?["xdm.pushNotificationTracking.customAction.actionID"] as? String)
    }
    
    func test_notificationTracking_whenUser_tapsNotificationActionThatOpensTheApp() {
        // setup
        setExpectationEvent(type: EventType.edge, source: EventSource.requestContent, expectedCount: 1)
        let response = prepareNotificationResponse(actionIdentifier: "ForegroundActionId", categoryIdentifier: "CategoryId")!
        
        // test
        Messaging.handleNotificationResponse(response)
        
        // verify
        let events = getDispatchedEventsWith(type: EventType.edge, source: EventSource.requestContent)
        XCTAssertEqual(1, events.count)
        let edgeEvent = events.first!
        let flattenEdgeEvent = edgeEvent.data?.flattening()
        
        // verify push tracking information
        XCTAssertEqual(1, flattenEdgeEvent?["xdm.application.launches.value"] as? Int)
        XCTAssertEqual("pushTracking.customAction", flattenEdgeEvent?["xdm.eventType"] as? String)
        XCTAssertEqual("ForegroundActionId",flattenEdgeEvent?["xdm.pushNotificationTracking.customAction.actionID"] as? String)
    }
    
    
    func test_notificationTracking_whenUser_tapsNotificationActionThatDoNotOpenTheApp() {
        // setup
        setExpectationEvent(type: EventType.edge, source: EventSource.requestContent, expectedCount: 1)
        let response = prepareNotificationResponse(actionIdentifier: "DeclineActionId", categoryIdentifier: "CategoryId")!
        
        // test
        Messaging.handleNotificationResponse(response)
        
        // verify
        let events = getDispatchedEventsWith(type: EventType.edge, source: EventSource.requestContent)
        XCTAssertEqual(1, events.count)
        let edgeEvent = events.first!
        let flattenEdgeEvent = edgeEvent.data?.flattening()
        
        // verify push tracking information
        XCTAssertEqual(0, flattenEdgeEvent?["xdm.application.launches.value"] as? Int)
        XCTAssertEqual("pushTracking.customAction", flattenEdgeEvent?["xdm.eventType"] as? String)
        XCTAssertEqual("DeclineActionId",flattenEdgeEvent?["xdm.pushNotificationTracking.customAction.actionID"] as? String)
    }
    
    func test_notificationTracking_whenUser_tapsNotificationActionThatDoNotOpenTheApp_Case2() {
        // This test simulates clicking on a notification action button for which notification options buttons are empty
        // setup
        setExpectationEvent(type: EventType.edge, source: EventSource.requestContent, expectedCount: 1)
        let response = prepareNotificationResponse(actionIdentifier: "notForegroundActionId", categoryIdentifier: "CategoryId")!
        
        // test
        Messaging.handleNotificationResponse(response)
        
        // verify
        let events = getDispatchedEventsWith(type: EventType.edge, source: EventSource.requestContent)
        XCTAssertEqual(1, events.count)
        let edgeEvent = events.first!
        let flattenEdgeEvent = edgeEvent.data?.flattening()
        
        // verify push tracking information
        XCTAssertEqual(0, flattenEdgeEvent?["xdm.application.launches.value"] as? Int)
        XCTAssertEqual("pushTracking.customAction", flattenEdgeEvent?["xdm.eventType"] as? String)
        XCTAssertEqual("notForegroundActionId",flattenEdgeEvent?["xdm.pushNotificationTracking.customAction.actionID"] as? String)
    }
    
    
    // MARK: - Private Helpers functions
    
    private func prepareNotificationResponse(withUserInfo userInfo : [String:Any] = mockUserInfo,
                                             actionIdentifier: String = UNNotificationDefaultActionIdentifier,
                                             categoryIdentifier: String = "") -> UNNotificationResponse? {
        let dateInfo = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.userInfo = userInfo
        notificationContent.categoryIdentifier = categoryIdentifier

        let request = UNNotificationRequest(identifier: "messageId" , content: notificationContent, trigger: trigger)
        guard let response = UNNotificationResponse(coder: MockNotificationResponseCoder(with: request,
                                                                                         actionIdentifier:actionIdentifier)) else {
            XCTFail()
            return nil
        }
        return response
    }
    
    private func setNotificationCategories() {
        let acceptAction = UNNotificationAction(identifier: "ForegroundActionId",
              title: "Foreground",
              options: [.foreground])
        let declineAction = UNNotificationAction(identifier: "DeclineActionId",
              title: "Decline",
              options: [.destructive,.authenticationRequired])
        let notForegroundAction = UNNotificationAction(identifier: "notForegroundActionId",
              title: "NotForeground",
              options: [])
        // Define the notification type
        let meetingInviteCategory =
              UNNotificationCategory(identifier: "CategoryId",
              actions: [acceptAction, declineAction, notForegroundAction],
              intentIdentifiers: [],
              hiddenPreviewsBodyPlaceholder: "",
              options: .customDismissAction)
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])
    }
    
}
