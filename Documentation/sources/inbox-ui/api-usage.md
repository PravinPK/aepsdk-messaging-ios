# APIs Usage

This document provides information on how to use the Messaging APIs to receive and display an Inbox UI in your application.

## Importing Messaging

To use the Messaging APIs, you need to import the Messaging module in your Swift file.

```swift
import AEPMessaging
```

## APIs

### getInboxUI

The `getInboxUI` method creates and returns an [InboxUI](./public-classes/inboxui.md) instance for the provided surface. The `InboxUI` starts in a loading state and automatically fetches inbox settings and content cards, transitioning through loading, loaded, or error states as needed.

#### Parameters

- _surface_ - The [Surface](../propositions/developer-documentation/classes/surface.md) for which to retrieve the inbox.
- _customizer_ - An optional [ContentCardCustomizing](../content-card-ui/public-classes/contentcardcustomizing.md) object to customize the appearance of the content cards within the inbox. If you do not need to customize the appearance of the content cards, this parameter can be omitted.
- _listener_ - An optional [InboxEventListening](./public-classes/inboxeventlistening.md) object to listen to state and interaction events from the inbox. If you do not need to listen to events, this parameter can be omitted.

> **Note** - This API returns an `InboxUI` immediately. The inbox will not have content until `updatePropositionsForSurfaces` has been called with the same surface. Call [`updatePropositionsForSurfaces`](../propositions/developer-documentation/api-usage.md#updatePropositionsForSurfaces) to download content from Adobe Journey Optimizer prior to or after calling this API.

#### Syntax

```swift
@available(iOS 15.0, *)
public static func getInboxUI(for surface: Surface,
                              customizer: ContentCardCustomizing? = nil,
                              listener: InboxEventListening? = nil) -> InboxUI
```

#### Example

```swift
// Create a surface matching your Adobe Journey Optimizer campaign configuration
let inboxSurface = Surface(path: "inbox")

// Get the InboxUI instance
let inboxUI = Messaging.getInboxUI(for: inboxSurface)

// Display the inbox view in SwiftUI
struct InboxPage: View {
    var body: some View {
        inboxUI.view
            .onAppear {
                Messaging.updatePropositionsForSurfaces([inboxSurface])
            }
    }
}
```

#### Example with Listener and Customizer

```swift
let inboxSurface = Surface(path: "inbox")

let inboxUI = Messaging.getInboxUI(
    for: inboxSurface,
    customizer: MyCardCustomizer(),
    listener: self
)
```

---

### updatePropositionsForSurfaces

Dispatches a network request to fetch propositions for the provided surfaces from Adobe Journey Optimizer. Call this API to download the latest content cards and inbox settings before displaying the inbox.

For full documentation on this API, see [Propositions API Usage](../propositions/developer-documentation/api-usage.md#updatePropositionsForSurfaces).

#### Syntax

```swift
public static func updatePropositionsForSurfaces(_ surfaces: [Surface])
```

#### Example

```swift
let inboxSurface = Surface(path: "inbox")
Messaging.updatePropositionsForSurfaces([inboxSurface])
```

---

## Typical Usage Flow

1. Register and configure the AEPMessaging extension at app launch.
2. Call `Messaging.updatePropositionsForSurfaces` to download inbox content from the server.
3. Call `Messaging.getInboxUI(for:)` to obtain an `InboxUI` instance.
4. Display the inbox using the `InboxUI.view` property in your SwiftUI or UIKit view.
5. Optionally assign a listener and customizer to respond to events and style the inbox.

```swift
import SwiftUI
import AEPMessaging

struct InboxPage: View {
    let inboxUI: InboxUI

    init() {
        let surface = Surface(path: "inbox")
        inboxUI = Messaging.getInboxUI(for: surface)
        inboxUI.isPullToRefreshEnabled = true
    }

    var body: some View {
        NavigationView {
            inboxUI.view
                .navigationTitle("Inbox")
        }
        .onAppear {
            Messaging.updatePropositionsForSurfaces([Surface(path: "inbox")])
        }
    }
}
```

## Next Steps

- [Displaying Inbox](./tutorial/displaying-inbox.md) - Detailed guide on displaying an Inbox in SwiftUI and UIKit
- [Listening to Inbox Events](./tutorial/listening-inbox-events.md) - Respond to inbox state changes and card interactions
- [Customizing Your Inbox](./tutorial/customizing-inbox.md) - Customize appearance, spacing, and views
