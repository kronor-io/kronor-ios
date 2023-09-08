//
//  CreditCardHeaderView.swift
//
//
//  Created by lorenzo on 2023-01-18.
//


import SwiftUI
import KronorApi
import Kronor

struct CreditCardHeaderView: View {
    @ObservedObject var viewModel: EmbeddedPaymentViewModel

    var body: some View {
        VStack {
            HStack() {
                Spacer()
                VStack {
                    Image(systemName:
                            [.errored, .paymentRejected].contains(viewModel.state.hashableIdentifier) ? "creditcard.trianglebadge.exclamationmark" : "creditcard")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.frame(width: 150,
                        height: 250,
                        alignment: .leading)
                Spacer()
            }
        }.frame(width: 350,
                height: 350,
                alignment: .leading)
    }
}

struct CreditCardHeaderView_Previews: PreviewProvider {
    static let viewModel = Preview.makeEmbeddedPaymentViewModel(paymentMethod: .mobilePay)
    static let errorViewModel = Preview.makeEmbeddedPaymentViewModel(
        paymentMethod: .mobilePay,
        state: .errored(
            error: .usageError(
                error: KronorApi.APIError(
                    errors: [],
                    extensions: [:]
                )
            )
        )
    )

    static var previews: some View {
        WrapperView(header: CreditCardHeaderView(viewModel: viewModel)) {
            Text("Dummy contents")
        }
        .previewDisplayName("Header")

        WrapperView(header: CreditCardHeaderView(viewModel: errorViewModel)) {
            Text("Dummy contents")
        }
        .previewDisplayName("Header Error")
    }
}
