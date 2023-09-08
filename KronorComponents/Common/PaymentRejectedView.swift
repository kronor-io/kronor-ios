//
//  PaymentRejectedView.swift
//  
//
//  Created by lorenzo on 2023-01-19.
//

import SwiftUI

struct PaymentRejectedView: View {
    var viewModel: RetryableModel
    
    @State var clickedOnSomething = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.red)
                    
                Text(
                    "payment_rejected",
                    bundle: .module,
                     comment: "indicates that the payment resulted in error, cancelled by the customer or declined by the provider"
                )
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
                    viewModel.cancel()
                    clickedOnSomething = true
                }) {
                    Text(
                        "cancel",
                        bundle: .module,
                        comment: "Indicates that the user wants to cancel the payment session and go back to the checkout"
                    )
                }
                .padding(.vertical)
                
                Text("or")
                    .font(.caption)
                
                Button(action: {
                    viewModel.retry()
                    clickedOnSomething = true
                }) {
                    Text(
                        "try_again",
                        bundle: .module,
                        comment: "Indicates that the user wants to continue the payment session and try another payment"
                    )
                }
                .padding(.vertical)
            }
        }
    }
}

struct PaymentRejectedView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentRejectedView(viewModel: PreviewRetryable())
    }
}

struct PreviewRetryable: RetryableModel {
    func cancel() {
    }

    func retry() {
    }
}
