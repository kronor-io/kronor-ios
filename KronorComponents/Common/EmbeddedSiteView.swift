//
//  EmbeddedSiteView.swift
//  
//
//  Created by lorenzo on 2023-02-02.
//

import SwiftUI

struct EmbeddedSiteView: View {
    let webViewModel: WebViewModel
    let url: URL
    @State var alertIsPresenting = false
    let onCancel: () -> ()
    
    var body: some View {
        NavigationView {
            SwiftUIWebView(viewModel: webViewModel, url: url)
                .navigationBarItems(
                    trailing: Button(action: {
                        alertIsPresenting = true
                    }) {
                        Text(
                            NSLocalizedString(
                                "cancel",
                                bundle: .module,
                                comment: "Abort the payment"
                            )
                            .capitalized
                        )
                        .bold()
                    })
                .alert(isPresented: $alertIsPresenting) {
                    Alert(
                        title: Text(
                            "cancel_payment",
                            bundle: .module,
                            comment:  "Alert message to ask the user if they want to cancel the payment"
                        ),
                        primaryButton: .default(
                            Text(
                                "continue",
                                bundle: .module,
                                comment:  "Continue in the same payment session"
                            ),
                            action: {}
                        ),
                        secondaryButton: .destructive(
                            Text(
                                "confirm_cancellation",
                                bundle: .module,
                                comment:  "Abort the payment"
                            ),
                            action: onCancel
                        )
                    )
                }
        }
    }
}

struct EmbeddedSiteView_Previews: PreviewProvider {
    static var previews: some View {
        EmbeddedSiteView(
            webViewModel: WebViewModel(),
            url: URL(string: "https://example.com")!,
            onCancel: { print("cancel") }
        )
    }
}
