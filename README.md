# Kronor iOS

Kronor iOS provides payments components that you can use to create a custom checkout solution for your customers
by using any of our provided payment methods.

## Installation

The recommended installation procedure is to use the [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app):

* Use https://github.com/kronor-io/kronor-ios as the repository URL
* You can add all modules, but you will at least need `Kronor` and `KronorComponents`


## Using Components with SwiftUI

You can use each payment method individually using in your own checkout flow by including any of our provided components.
Here's an example of including the `Swish` payment method:

```swift
import SwiftUI
import KronorComponents

struct CheckoutView: View {

    @State var sessionToken: String

    var body: some View {
        VStack {
            Spacer()

            SwishComponent(
                configuration: .init(
                    env: .production,
                    sessionToken: sessionToken,
                    returnURL: URL(string: "myapp://")!
                )
            ) { result in
                // Handle payment result here
            }

            Spacer()
        }
    }
}
```

The `sessionToken` variable needs to be provided from the backend, by using the `newPaymentSession` query
as [described in the docs](https://docs.kronor.io/payment-gateway-sdk#payment-session)

## Google Pay

Google Pay has no native iOS SDK, so `GooglePayComponent` runs the payment on
Kronor's hosted payment page in an `ASWebAuthenticationSession` (a real Safari
context, required by the Google Pay web API). The customer needs to be signed
in to a Google account with a saved card:

```swift
GooglePayComponent(
    configuration: .init(
        env: .production,
        sessionToken: sessionToken,
        returnURL: URL(string: "myapp://")!
    )
) { result in
    // Handle payment result here
}
```
