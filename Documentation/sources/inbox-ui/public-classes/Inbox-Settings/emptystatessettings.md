# EmptyStateSettings

Contains the server-provided configuration for the inbox empty state — displayed when the inbox has no content cards to show.

## Struct Definition

```swift
public struct EmptyStateSettings: Codable
```

## Public Properties

| Property | Type | Description |
| --- | --- | --- |
| `message` | [`AEPText?`](../../../content-card-ui/public-classes/UIElements/aeptext.md) | Optional text message to display in the empty state. Configured in Adobe Journey Optimizer. |
| `image` | [`AEPImage?`](../../../content-card-ui/public-classes/UIElements/aepimage.md) | Optional image to display in the empty state. Configured in Adobe Journey Optimizer. |

## Usage

`EmptyStateSettings` is passed to the custom empty view builder set via `InboxUI.setEmptyView(_:)`. Use server-provided values when available and fall back to your own defaults otherwise.

```swift
inboxUI.setEmptyView { emptyStateSettings in
    AnyView(
        VStack(spacing: 16) {
            if let image = emptyStateSettings?.image {
                image.view
                    .frame(maxWidth: 120, maxHeight: 120)
            } else {
                Image(systemName: "tray")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            }

            if let message = emptyStateSettings?.message {
                message.view
                    .multilineTextAlignment(.center)
            } else {
                Text("No messages")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    )
}
```
