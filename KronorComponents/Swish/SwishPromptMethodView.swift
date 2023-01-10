//
//  SwishPromptMethodView.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-04.
//

import SwiftUI

struct SwishPromptMethodView: View {
    var viewModel : SwishPaymentViewModel
    
    var body: some View {
        VStack {
            Spacer()

            Button(action: {
                Task {
                    await viewModel.transition(.useSwishApp)
                }
            }) { Text("Open Swish App") }
                .disabled(!viewModel.swishAppInstalled)

            Spacer()
            
            Text("or pay using another phone")
                .fontWeight(.thin)
                .foregroundColor(Color.gray)
                .padding(.vertical)
            
            Button(action: {
                Task {
                    await viewModel.transition(.useQR)
                }
            }) { Text("Scan QR Code") }
                .padding(.top)
            
            Button(action: {
                Task {
                    await viewModel.transition(.usePhoneNumber)
                }
            }) { Text("Enter phone number") }
                .padding(.vertical)

            Text(String())
        }
    }
}

struct SwishPromptMethodView_Previews: PreviewProvider {
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
            SwishPromptMethodView(viewModel: viewModel)
        }
    }
}
