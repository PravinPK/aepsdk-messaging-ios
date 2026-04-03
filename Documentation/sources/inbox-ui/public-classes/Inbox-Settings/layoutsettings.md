# LayoutSettings

Controls the layout orientation of content cards within an inbox.

## Struct Definition

```swift
public struct LayoutSettings: Codable
```

## Public Properties

| Property | Type | Description |
| --- | --- | --- |
| `orientation` | [`InboxOrientation`](#inboxorientation) | The direction in which content cards are arranged. |

---

## InboxOrientation

An enum specifying the layout direction of content cards in the inbox.

### Enum Definition

```swift
public enum InboxOrientation: String, CaseIterable {
    case horizontal = "horizontal"
    case vertical = "vertical"
}
```

### Cases

| Case | Raw Value | Description |
| --- | --- | --- |
| `horizontal` | `"horizontal"` | Content cards are arranged in a horizontal scrollable row. |
| `vertical` | `"vertical"` | Content cards are stacked vertically in a scrollable list. |
