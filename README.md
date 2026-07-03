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

    let sessionToken: String

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

## Avarda

`AvardaComponent` handles Avarda buy-now-pay-later payments on Kronor's hosted
payment page, which collects the customer's national identification number and
redirects to Avarda's checkout for identification:

```swift
AvardaComponent(
    configuration: .init(
        env: .production,
        sessionToken: sessionToken,
        returnURL: URL(string: "myapp://")!
    ),
    buyNowPayLaterProduct: .directInvoice
) { result in
    // Handle payment result here
}
```

## Apple Pay

The `ApplePayComponent` provides a native (in-app) Apple Pay flow using PassKit.
In addition to the shared configuration it needs the Apple Pay merchant identifier
registered in your Apple developer account, and your app must have the
`com.apple.developer.in-app-payments` entitlement for that merchant identifier:

```swift
import SwiftUI
import KronorComponents

struct ApplePayCheckoutView: View {

    let sessionToken: String

    var body: some View {
        if ApplePayComponent.canMakePayments() {
            ApplePayComponent(
                configuration: .init(
                    env: .production,
                    sessionToken: sessionToken,
                    returnURL: URL(string: "myapp://")!
                ),
                merchantIdentifier: "merchant.com.example.shop",
                merchantName: "Example Shop"
            ) { result in
                // Handle payment result here
            }
        }
    }
}
```

Use `ApplePayComponent.canMakePayments()` to decide whether to offer Apple Pay
as a payment method on the current device.
