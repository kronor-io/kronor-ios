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
            }) {
                Text(
                    "open_swish",
                    bundle: .module,
                    comment: "A button label that indicates the customer wants to pay with the Swish app in the same device"
                )
            }
                .disabled(!viewModel.swishAppInstalled)

            Spacer()
            
            
            Text(
                "pay_another_phone",
                bundle: .module,
                comment: ""
            )
                .fontWeight(.thin)
                .foregroundColor(Color.gray)
                .padding(.vertical)
            
            Button(action: {
                Task {
                    await viewModel.transition(.useQR)
                }
            }) {
                Text(
                    "scan_qr_code",
                    bundle: .module,
                    comment: "A button label that indicates the customer wants to pay by scanning a QR code in another device"
                )
            }
                .padding(.top)
            
            Button(action: {
                Task {
                    await viewModel.transition(.usePhoneNumber)
                }
            }) {
                Text(
                    "enter_phone",
                    bundle: .module,
                    comment: "A button label that indicates the customer wants to pay getting a notification in another device"
                )
                
            }
                .padding(.vertical)

            Text(String())
        }
    }
}

struct SwishPromptMethodView_Previews: PreviewProvider {
    static let viewModel = Preview.makeSwishPaymentViewModel()

    static var previews: some View {
        SwishWrapperView {
            SwishPromptMethodView(viewModel: viewModel)
        }
    }
}
