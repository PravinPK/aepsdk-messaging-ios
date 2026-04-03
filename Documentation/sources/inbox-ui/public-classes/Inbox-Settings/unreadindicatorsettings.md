# UnreadIndicatorSettings

Contains the server-provided configuration for the unread indicator — a visual badge displayed on content cards that have not yet been read.

## Struct Definition

```swift
public struct UnreadIndicatorSettings: Codable
```

## Public Properties

| Property | Type | Description |
| --- | --- | --- |
| `unreadBackground` | [`UnreadBackgroundSettings?`](#unreadbackgroundsettings) | Optional configuration for the background color of the unread indicator. |
| `unreadIcon` | [`UnreadIconSettings?`](#unreadiconsettings) | Optional configuration for the icon image and its placement within the unread indicator. |

---

## UnreadBackgroundSettings

Configuration for the background color of the unread indicator.

### Struct Definition

```swift
public struct UnreadBackgroundSettings: Codable
```

### Public Properties

| Property | Type | Description |
| --- | --- | --- |
| `color` | `AEPColor` | The background color of the unread indicator badge. |

---

## UnreadIconSettings

Configuration for the icon and placement of the unread indicator.

### Struct Definition

```swift
public struct UnreadIconSettings: Codable
```

### Public Properties

| Property | Type | Description |
| --- | --- | --- |
| `placement` | [`IconPlacement`](./iconplacement.md) | The corner of the content card where the unread indicator is displayed. |
| `image` | [`AEPImage`](../../../content-card-ui/public-classes/UIElements/aepimage.md) | The image used as the unread indicator icon. |
