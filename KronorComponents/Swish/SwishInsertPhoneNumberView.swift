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
            TextField("Entrer your Swish phone number", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal)
            
            let isClickable = !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            && phoneNumber.count >= 8
            
            Button(action: {
                if isClickable {
                    Task {
                        await viewModel.transition(.phoneNumberInserted(number: phoneNumber))
                    }
                }
            }) { Text("Pay Now") }
                .disabled(!isClickable)
                .padding()
            Spacer()
        }
    }
}

struct SwishInsertPhoneNumberView_Previews: PreviewProvider {
    static let machine = SwishStatechart.makeStateMachine()
    
    static var previews: some View {
        let viewModel = SwishPaymentViewModel(
            sessionToken: "dummy",
            stateMachine: machine,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishWrapperView {
            SwishInsertPhoneNumberView(viewModel: viewModel)
        }
    }
}
