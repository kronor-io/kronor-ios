//
//  SwishPaymentRejectedView.swift
//  kronor-test-app
//
//  Created by lorenzo on 2023-01-09.
//

import SwiftUI

struct SwishPaymentRejectedView: View {
    var viewModel: SwishPaymentViewModel
    
    @State var clickedOnSomething = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.red)
                    
                Text("Payment failed")
                    .font(.headline)
                    .foregroundColor(Color.red)
                    
                Spacer()
            }
            .padding(.bottom)
            
            Spacer()
            if clickedOnSomething {
               Spacer()
            } else {
                Button(action: {
                    Task {
                        await viewModel.transition(.cancelFlow)
                    }
                    clickedOnSomething = true
                }) {
                    Text("cancel")
                }
                .padding(.vertical)
                
                Text("or")
                    .font(.caption)
                
                Button(action: {
                    Task {
                        await viewModel.transition(.retry)
                    }
                    clickedOnSomething = true
                }) {
                    Text("try again?")
                }
                .padding(.vertical)
            }
        }
    }
}

struct SwishPaymentRejectedView_Previews: PreviewProvider {
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
            SwishPaymentRejectedView(viewModel: viewModel)
        }
    }
}
