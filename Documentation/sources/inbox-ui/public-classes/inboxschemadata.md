# InboxSchemaData

Represents the server-provided schema data for an inbox, decoded from an Adobe Journey Optimizer inbox proposition item. This data drives the layout, heading, empty state, and unread indicator behavior of the [InboxUI](../inboxui.md).

## Class Definition

```swift
public class InboxSchemaData: NSObject, Codable
```

## Public Properties

| Property | Type | Description |
| --- | --- | --- |
| `content` | [`InboxSettings`](./Inbox-Settings/inboxsettings.md) | The inbox settings decoded from the server payload, containing layout, heading, capacity, empty state, and unread indicator configuration. |

## Usage

`InboxSchemaData` is available as the `inboxSchemaData` property on [InboxUI](../inboxui.md). It is set automatically once the inbox loads, and is `nil` while in the loading state.

```swift
let inboxUI = Messaging.getInboxUI(for: Surface(path: "inbox"))

// After the inbox loads, inboxSchemaData is populated
if let schemaData = inboxUI.inboxSchemaData {
    print("Layout: \(schemaData.content.layout.orientation)")
    print("Capacity: \(schemaData.content.capacity)")
}
```
