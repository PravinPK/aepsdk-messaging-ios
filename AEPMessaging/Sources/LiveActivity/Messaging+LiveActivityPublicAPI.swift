/*
 Copyright 2025 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

#if canImport(ActivityKit)
    import ActivityKit
#endif

import AEPCore
import AEPMessagingLiveActivity
import AEPServices

// Extension for Messaging class for Live Activity public APIs
@available(iOS 16.1, *)
public extension Messaging {
    // MARK: - Shared Storage

    /// A shared task store for tasks that handle push-to-start token updates.
    private static let pushToStartTaskStore = ActivityTaskStore<String>()

    /// A shared task store for tasks that handle Live Activity update tokens and state transitions.
    private static let activityUpdateTaskStore = ActivityTaskStore<String>()

    /// Registers a Live Activity type with the Adobe Experience Platform SDK.
    ///
    /// When called, this method enables the SDK to:
    /// - Automatically collect push-to-start tokens for devices running iOS 17.2 or later
    /// - Manage the complete lifecycle of Live Activities including:
    ///   - Automatically collect the generated Live Activity update token
    ///   - Monitor state transitions (start, update, end)
    ///   - Event tracking for the registered activity type
    ///
    /// - Parameter type: The Live Activity type that conforms to the ``LiveActivityAttributes`` protocol.
    ///                   This type defines the structure and content of your Live Activity.
    static func registerLiveActivity<T: LiveActivityAttributes>(_: T.Type) {
        let attributeType = T.attributeType
        
        // Dispatch attribute structure event
        dispatchAttributeStructureEvent(type: T.self)

        if #available(iOS 17.2, *) {
            let newPushTask = createPushToStartTokenTask(type: T.self)
            Task {
                await pushToStartTaskStore.setTask(for: attributeType, task: newPushTask)
            }
        } else {
            Log.debug(
                label: MessagingConstants.LOG_TAG,
                "Not creating a Live Activity push-to-start token handler task for " +
                    "LiveActivityAttributes type \(attributeType). " +
                    "iOS 17.2 or later is required to start a Live Activity with a push-to-start token."
            )
        }

        let newActivityUpdatesTask = createActivityUpdatesTask(type: T.self)
        Task {
            await activityUpdateTaskStore.setTask(for: attributeType, task: newActivityUpdatesTask)
        }
    }

    // MARK: - Private Helper Functions

    /// Creates and returns a `Task` that listens for push-to-start token updates.
    ///
    /// This task observes the `pushToStartTokenUpdates` asynchronous sequence from `ActivityKit`
    /// and converts each received token into a hexadecimal string. If the token is new (not previously stored),
    /// it dispatches a push-to-start event to notify the system. Duplicate tokens are ignored to avoid redundant processing.
    ///
    /// - Parameters:
    ///   - type: The concrete type conforming to ``LiveActivityAttributes`` used to access the associated `Activity`.
    /// - Returns: A `Task` that runs indefinitely, monitoring and responding to incoming push-to-start tokens.
    ///            The task completes only if the underlying sequence ends or the task is explicitly cancelled.
    @available(iOS 17.2, *)
    private static func createPushToStartTokenTask<T: LiveActivityAttributes>(type _: T.Type) -> Task<Void, Never> {
        Task {
            let attributeType = T.attributeType

            // Remove this task from storage when the sequence ends.
            defer {
                Task {
                    await pushToStartTaskStore.removeTask(for: attributeType)
                }
            }

            for await tokenData in Activity<T>.pushToStartTokenUpdates {
                let tokenHex = tokenData.hexEncodedString
                dispatchPushToStartTokenEvent(attributeType: attributeType, token: tokenHex)
            }
        }
    }

    /// Creates and returns a `Task` that listens for activity updates.
    ///
    /// This task observes the `activityUpdates` asynchronous sequence from `ActivityKit` for the given Live Activity type.
    /// When a new activity starts, it dispatches a start event and creates child tasks to monitor state transitions
    /// and push token updates specific to that activity.
    ///
    /// - Parameters:
    ///   - type: The concrete type conforming to ``LiveActivityAttributes`` used to observe Live Activity lifecycle and token updates.
    /// - Returns: A `Task` that runs indefinitely, listening for new Live Activities and setting up listeners
    ///            for their state changes and push token updates. The task completes only if the underlying sequence ends
    ///            or the task is explicitly cancelled.
    private static func createActivityUpdatesTask<T: LiveActivityAttributes>(type _: T.Type) -> Task<Void, Never> {
        Task {
            let attributeType = T.attributeType

            // Remove this task from storage when the sequence ends.
            defer {
                Task {
                    await activityUpdateTaskStore.removeTask(for: attributeType)
                }
            }

            for await activity in Activity<T>.activityUpdates {
                // Dispatch Live Activity start tracking event
                dispatchStartEvent(activity: activity)

                // Use task group to manage state and push token updates concurrently.
                await withTaskGroup(of: Void.self) { group in
                    // Listen for state updates.
                    group.addTask {
                        for await newState in activity.activityStateUpdates {
                            if newState == .dismissed || newState == .ended {
                                dispatchStateUpdateEvent(activity: activity, state: newState)
                            }
                        }
                    }

                    // Listen for push token updates for this activity.
                    // Live Activities Broadcast via channels do not use this token.
                    group.addTask {
                        for await newTokenData in activity.pushTokenUpdates {
                            let newTokenHex = newTokenData.hexEncodedString
                            Log.debug(label: MessagingConstants.LOG_TAG, "Update token received for activity \(activity.id) (\(attributeType)): \(newTokenHex)")
                            dispatchUpdateTokenEvent(activity: activity, token: newTokenHex)
                        }
                    }
                }
            }
        }
    }

    /// Dispatches an event indicating that a Live Activity push-to-start token has been received.
    ///
    /// This method constructs and dispatches an event to Messaging extension that represents
    /// the push-to-start token and associated details for a specific Live Activity type.
    ///
    /// - Parameters:
    ///   - attributeType: A unique string identifier representing the ``LiveActivityAttributes`` type associated with the Live Activity.
    ///   - token: A `String` representing the push-to-start token for the Live Activity.
    private static func dispatchPushToStartTokenEvent(attributeType: String, token: String) {
        Log.debug(label: MessagingConstants.LOG_TAG,
                  """
                  Dispatching Live Activity push-to-start token event.
                  Token: \(token)
                  Type: \(attributeType)
                  """)

        let eventName = "\(MessagingConstants.Event.Name.LIVE_ACTIVITY_PUSH_TO_START) for type (\(attributeType))"
        let event = Event(name: eventName,
                          type: EventType.messaging,
                          source: EventSource.requestContent,
                          data: [
                              MessagingConstants.Event.Data.Key.LIVE_ACTIVITY_PUSH_TO_START_TOKEN: true,
                              MessagingConstants.XDM.Push.TOKEN: token,
                              MessagingConstants.Event.Data.Key.ATTRIBUTE_TYPE: attributeType
                          ])
        MobileCore.dispatch(event: event)
    }

    /// Dispatches an event indicating that a Live Activity's push token has been updated.
    ///
    /// This method constructs and dispatches an event to Messaging extension that represents
    /// the update token and associated details for a specific Live Activity.
    ///
    /// - Parameters:
    ///   - activity: The `Activity` instance whose push token was updated. The activity must conform to ``LiveActivityAttributes``.
    ///   - token: A `String` representing the update push token for the Live Activity.
    /// - Note: This method will not dispatch an event if the Live Activity ID is missing.
    private static func dispatchUpdateTokenEvent<T: LiveActivityAttributes>(activity: Activity<T>, token: String) {
        let attributeType = T.attributeType
        guard let liveActivityID = activity.attributes.liveActivityData.liveActivityID else {
            Log.error(label: MessagingConstants.LOG_TAG,
                      """
                      Missing required '\(MessagingConstants.XDM.LiveActivity.ID)'. Update token event will not be sent.
                      Type: \(attributeType)
                      Apple Live Activity ID: \(activity.id)
                      """)
            return
        }

        Log.debug(label: MessagingConstants.LOG_TAG,
                  """
                  Dispatching Live Activity update token event.
                  Type: \(attributeType)
                  Apple Live Activity ID: \(activity.id)
                  LiveActivityID: \(liveActivityID))
                  Token: \(token)
                  """)

        let eventName = "\(MessagingConstants.Event.Name.LIVE_ACTIVITY_PUSH_TO_START) for type (\(attributeType))"

        let event = Event(name: eventName,
                          type: EventType.messaging,
                          source: EventSource.requestContent,
                          data: [
                              MessagingConstants.Event.Data.Key.LIVE_ACTIVITY_UPDATE_TOKEN: true,
                              MessagingConstants.XDM.Push.TOKEN: token,
                              MessagingConstants.Event.Data.Key.ATTRIBUTE_TYPE: attributeType,
                              MessagingConstants.Event.Data.Key.APPLE_LIVE_ACTIVITY_ID: activity.id,
                              MessagingConstants.XDM.LiveActivity.ID: liveActivityID
                          ])
        MobileCore.dispatch(event: event)
    }

    /// Dispatches an event indicating that a Live Activity has started.
    ///
    /// This method is used to send an event indicating the start of a Live Activity.
    ///
    /// - Parameter activity: The newly started `Activity` instance. The activity must conform to ``LiveActivityAttributes``.
    /// - Note: This method includes the Live Activity's origin and identifier data in the event.
    private static func dispatchStartEvent<T: LiveActivityAttributes>(activity: Activity<T>) {
        let attributeType = T.attributeType
        let liveActivityIdentifierData = activity.attributes.liveActivityIdentifierData

        Log.debug(label: MessagingConstants.LOG_TAG,
                  """
                  Dispatching Live Activity start event.
                  Type: \(attributeType)
                  Apple Live Activity ID: \(activity.id)
                  Identifier: \(liveActivityIdentifierData)
                  """)

        var data: [String: Any] = [
            MessagingConstants.Event.Data.Key.LIVE_ACTIVITY_TRACK_START: true,
            MessagingConstants.Event.Data.Key.ATTRIBUTE_TYPE: attributeType,
            MessagingConstants.Event.Data.Key.APPLE_LIVE_ACTIVITY_ID: activity.id,
            MessagingConstants.XDM.LiveActivity.ORIGIN: activity.attributes.liveActivityData.origin
        ]

        // Merge in the single identifier (liveActivityID or channelID)
        data.merge(liveActivityIdentifierData) { current, _ in current }

        let eventName = "\(MessagingConstants.Event.Name.LIVE_ACTIVITY_START) for type (\(attributeType))"
        let event = Event(name: eventName,
                          type: EventType.messaging,
                          source: EventSource.requestContent,
                          data: data)
        MobileCore.dispatch(event: event)
    }

    /// Dispatches an event to track a Live Activity state update.
    ///
    /// This method is used to send an event indicating a change in the state of a Live Activity,
    /// such as when it transitions to `.active`, `.ended`, or `.dismissed`.
    ///
    /// - Parameters:
    ///   - activity: The Live Activity instance whose state has changed. The activity must conform to ``LiveActivityAttributes``.
    ///   - state: The new `ActivityState` representing the current lifecycle state of the activity.
    /// - Note: This method includes the Live Activity's identifier data in the event.
    private static func dispatchStateUpdateEvent<T: LiveActivityAttributes>(
        activity: Activity<T>,
        state: ActivityState
    ) {
        let attributeType = T.attributeType
        let liveActivityIdentifierData = activity.attributes.liveActivityIdentifierData

        Log.debug(label: MessagingConstants.LOG_TAG,
                  """
                  Dispatching Live Activity \(state) event.
                  Type: \(attributeType)
                  Apple Live Activity ID: \(activity.id)
                  Identifier: \(liveActivityIdentifierData)
                  """)

        var data: [String: Any] = [
            MessagingConstants.Event.Data.Key.LIVE_ACTIVITY_TRACK_STATE: true,
            MessagingConstants.Event.Data.Key.ATTRIBUTE_TYPE: attributeType,
            MessagingConstants.Event.Data.Key.APPLE_LIVE_ACTIVITY_ID: activity.id,
            MessagingConstants.Event.Data.Key.STATE: "\(state)"
        ]

        // Merge in the single identifier (liveActivityID or channelID)
        data.merge(liveActivityIdentifierData) { current, _ in current }

        let eventName = "\(MessagingConstants.Event.Name.LIVE_ACTIVITY_STATE): \(state) for type (\(attributeType))"
        let event = Event(name: eventName,
                          type: EventType.messaging,
                          source: EventSource.requestContent,
                          data: data)
        MobileCore.dispatch(event: event)
    }

    // MARK: - Private Helper Functions for Attribute Structure
    
    /// Helper to extract the generic type from an Optional
    private static func extractGenericType(from typeName: String) -> String? {
        // Check if the type is an Optional
        if typeName.hasPrefix("Optional<") && typeName.hasSuffix(">") {
            // Extract the generic type
            let startIndex = typeName.index(typeName.startIndex, offsetBy: "Optional<".count)
            let endIndex = typeName.index(typeName.endIndex, offsetBy: -1)
            return String(typeName[startIndex..<endIndex])
        }
        return nil
    }
    
    /// Helper function to recursively explore object properties
    private static func exploreObject(_ value: Any) -> Any {
        let mirror = Mirror(reflecting: value)
        let typeName = String(describing: Swift.type(of: value))
        
        // Handle Optional values
        if mirror.displayStyle == .optional {
            // Check if we can extract the generic type from the typeName
            // Format is typically "Optional<Type>" but when nil it might not show in children
            if let genericType = extractGenericType(from: typeName) {
                return "Optional<\(genericType)>"
            }
            
            // If couldn't extract from type name, look at the value
            if let firstChild = mirror.children.first {
                return "Optional<\(String(describing: Swift.type(of: firstChild.value)))>"
            } else {
                // If it's nil, we need to infer the type from the typeName
                return typeName 
            }
        }
        
        // If this has no children or is an enum, return its type name
        if mirror.children.isEmpty || mirror.displayStyle == .enum {
            return typeName
        }
        
        // Otherwise, explore its structure
        var result: [String: Any] = [:]
        for child in mirror.children {
            if let label = child.label, !label.hasPrefix("_") {
                let childValue = child.value
                let childMirror = Mirror(reflecting: childValue)
                let childTypeName = String(describing: Swift.type(of: childValue))
                
                // Handle different cases
                if childMirror.displayStyle == .optional {
                    // Process optionals directly
                    if let genericType = extractGenericType(from: childTypeName) {
                        result[label] = "Optional<\(genericType)>"
                    } else if let firstChild = childMirror.children.first {
                        result[label] = "Optional<\(String(describing: Swift.type(of: firstChild.value)))>"
                    } else {
                        result[label] = childTypeName
                    }
                } else if childMirror.children.isEmpty || childMirror.displayStyle == .enum || childTypeName.hasPrefix("Swift.") {
                    // For Swift standard types, empty objects, or enums, just store the type name
                    result[label] = childTypeName
                } else {
                    // For custom types with properties, recursively explore
                    result[label] = exploreObject(childValue)
                }
            }
        }
        
        return result
    }


    // MARK: - Event Dispatch Methods
    
    /// Dispatches an event containing the structure of the LiveActivity attribute.
    ///
    /// This method constructs and dispatches an event that represents the structure
    /// of the LiveActivity attribute type, including its properties and their types.
    ///
    /// - Parameter type: The concrete type conforming to ``LiveActivityAttributes`` whose structure will be dispatched.
    private static func dispatchAttributeStructureEvent<T: LiveActivityAttributes>(type: T.Type) {
        let attributeType = T.attributeType
        
        // Build the attribute structure dictionary
        var attributeStructure: [String: Any] = [:]
        
        #if DEBUG
        // Only types that opt in to DebugInitialisable will be reflected
        if let debuggable = T.self as? any DebuggableLiveActivityAttributes.Type {
            let instance = debuggable.init()
            attributeStructure["attributes"] = exploreObject(instance)
            
            // Extract ContentState properties
            let contentStateProperties = getContentStateProperties(for: T.self)
            if !contentStateProperties.isEmpty {
                attributeStructure["content-state"] = contentStateProperties
            }
        }
        #endif
        
        // Add the attribute type - ensure this is always included
        attributeStructure["attributes-type"] = attributeType
        
        Log.debug(label: MessagingConstants.LOG_TAG,
                  """
                  Dispatching Live Activity attribute structure event.
                  Type: \(attributeType)
                  Structure: \(attributeStructure)
                  """)
        
        let eventName = "Live Activity Structure Event for (\(attributeType))"
        let event = Event(name: eventName,
                         type: EventType.messaging,
                         source: EventSource.requestContent,
                         data: [
                             "isAttributeStructureEvent": true,
                             MessagingConstants.Event.Data.Key.ATTRIBUTE_TYPE: attributeType,
                             "attributeStructure": attributeStructure
                         ])
        MobileCore.dispatch(event: event)
    }
    
    /// Gets the property structure of a ContentState type
    ///
    /// - Parameter type: The LiveActivityAttributes type containing the ContentState
    /// - Returns: Dictionary mapping property names to their type names
    private static func getContentStateProperties<T: LiveActivityAttributes>(for type: T.Type) -> [String: String] {
        let contentStateType = T.ContentState.self
        let contentStateTypeName = String(describing: contentStateType)
        Log.debug(label: MessagingConstants.LOG_TAG, "Getting properties for ContentState type: \(contentStateTypeName)")
        
        var properties: [String: String] = [:]
        
        // Try to get metadata from the ContentState if it conforms to _ExposesMetadata
        if let metadataProvider = contentStateType as? _ExposesMetadata.Type {
            Log.debug(label: MessagingConstants.LOG_TAG, "ContentState exposes metadata via macro")
            for (name, type) in metadataProvider.__metadata.properties {
                properties[name] = String(describing: type)
            }
            return properties
        }
        
        #if DEBUG
        // If no metadata is available, use our fallback approach
        if properties.isEmpty {
            Log.debug(label: MessagingConstants.LOG_TAG, "No macro metadata found, falling back to reflection")
            
            // Method 1: Use JSON parsing errors to discover required properties
            let emptyJson = "{}"
            if let data = emptyJson.data(using: .utf8) {
                do {
                    _ = try JSONDecoder().decode(T.ContentState.self, from: data)
                } catch let decodingError as DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, _):
                        // Found a required property
                        properties[key.stringValue] = "Unknown" // We don't know the type yet
                    default:
                        break
                    }
                } catch {
                    // Unknown error, fallback to other methods
                }
            }
            
            // Try to determine property types if we found any
            if !properties.isEmpty {
                for propertyName in properties.keys {
                    // Try with common types
                    for (value, typeName) in [("", "String"), (0, "Int"), (0.0, "Double"), (false, "Bool")] {
                        let jsonObj = [propertyName: value]
                        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) {
                            do {
                                _ = try JSONDecoder().decode(T.ContentState.self, from: jsonData)
                                // If we get here, we found the correct type
                                properties[propertyName] = typeName
                                break
                            } catch {
                                // Continue trying other types
                            }
                        }
                    }
                }
            }
        }
        #endif
        
        return properties
    }
    
    /// Protocol for types that expose metadata about their properties
    private protocol _ExposesMetadata {
        /// Get metadata about the type's properties
        static var __metadata: PropertyMetadata { get }
    }
    
    /// Represents metadata about a type's properties
    private struct PropertyMetadata {
        /// Array of tuples containing property name and type
        var properties: [(name: String, type: Any.Type)]
    }
}
