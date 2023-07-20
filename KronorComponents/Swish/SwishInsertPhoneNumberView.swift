//
//  SwishInsertPhoneNumberView.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-09.
//

import SwiftUI

struct SwishInsertPhoneNumberView: View {
    var viewModel : SwishPaymentViewModel

    @State var phoneNumber: String = ""
    
    var body: some View {
        VStack{
            Spacer()
            TextField(Bundle.module.localizedString(forKey: "Entrer your Swish phone number", value: nil, table: nil), text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal)
            
            let isClickable = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
            
            Button(action: {
                if isClickable {
                    Task {
                        await viewModel.transition(.phoneNumberInserted(number: phoneNumber))
                    }
                }
            }) {
                Text(
                    "pay_now",
                    bundle: .module,
                    comment: "Call to action after entering the Swish phone number to make a payment"
                )
            }
                .disabled(!isClickable)
                .padding()
            Spacer()
        }
    }
}

struct SwishInsertPhoneNumberView_Previews: PreviewProvider {
    static let machine = SwishStatechart.makeStateMachine()
    static let networking = KronorSwishPaymentNetworking(
        env: .sandbox,
        token: "dummy"
    )
    
    static var previews: some View {
        let viewModel = SwishPaymentViewModel(
            stateMachine: machine,
            networking: networking,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishWrapperView {
            SwishInsertPhoneNumberView(viewModel: viewModel)
        }
    }
}
