//
//  CreditCardWaitingView.swift
//
//
//  Created by lorenzo on 2023-01-24.
//

import SwiftUI

struct CreditCardWaitingView: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "hourglass.circle")
            Text(
                "Establishing secure connection",
                bundle: .module,
                comment:  "A waiting message that indicates the app is communicating with the server"
            )
                .font(.subheadline)
            Spacer()
        }
    }
}

struct CreditCardWaitingView_Previews: PreviewProvider {
    static let viewModel = Preview.makeEmbeddedPaymentViewModel(paymentMethod: .mobilePay)

    static var previews: some View {
        WrapperView(header: CreditCardHeaderView(viewModel: viewModel)) {
            CreditCardWaitingView()
        }
    }
}
