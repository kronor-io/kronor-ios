//
//  SwishPaymentView.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-04.
//

import SwiftUI

struct SwishPaymentView: View {
    @ObservedObject var viewModel: SwishPaymentViewModel
    
    var body: some View {
        SwishWrapperView(content: generateContentView)
    }

    @ViewBuilder func generateContentView() -> some View {
        switch viewModel.state {
        case .promptingMethod:
            SwishPromptMethodView(viewModel: viewModel)
        case .insertingPhoneNumber:
            SwishInsertPhoneNumberView(viewModel: viewModel)
        case .creatingPaymentRequest, .waitingForPaymentRequest:
            HStack {
                Spacer()
                Image(systemName: "hourglass.circle")
                Text(
                    "Creating secure Swish transaction",
                    bundle: .module,
                    comment:  "A waiting message that indicates that the app is communicating with the server"
                )
                .font(.subheadline)
                Spacer()
            }
        case .paymentRequestInitialized(.swishApp):
            HStack {
                Spacer()
                Image(systemName: "arrow.up.forward.app")
                Text(
                    "Opening the swish app",
                    bundle: .module,
                    comment:  "Indicates that this app is prompting the user to open the Swish app in the same device"
                )
                .font(.subheadline)

                Spacer()
            }
        case .paymentRequestInitialized(.qrCode):
            if let qrCode = viewModel.qrCode {
                SwishQRView(qrCode: qrCode)
            } else {
                HStack {
                    Spacer()
                    Image(systemName: "qrcode.viewfinder")
                    Text(
                        "Generating QR code",
                        bundle: .module,
                        comment:  "A waiting message indicating that a new QR code image is being generated"
                    )
                    .font(.subheadline)

                    Spacer()
                }
            }
        case .paymentRequestInitialized(.phoneNumber):
            HStack {
                Spacer()
                Image(systemName: "arrow.up.forward.app")
                Text(
                    "You can pay with the Swish app now",
                    bundle: .module,
                    comment:  "A waiting message indicating that the customer should open the Swish app in another phone"
                )
                .font(.headline)

                Spacer()
            }
        case .waitingForPayment:
            HStack {
                Spacer()
                Image(systemName: "hourglass.circle")
                Text(
                    "Completing payment",
                    bundle: .module,
                    comment:  "A waiting message indicating that the customer should complete the payment in the Swish app"
                )
                .font(.subheadline)
                Spacer()
            }
        case .paymentRejected:
            PaymentRejectedView(viewModel: self.viewModel)
        case .paymentCompleted:
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle")
                    .foregroundColor(Color.green)

                Text(
                    "Payment completed",
                    bundle: .module,
                    comment:  "A success message indicating that the payment was completed and the payment session will end"
                )
                .font(.headline)
                .foregroundColor(Color.green)

                Spacer()
            }
        case .errored(_):
            HStack {
                Spacer()
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.red)

                Text(
                    "Could not complete the payment due to an error. Please try again after a short time",
                    bundle: .module,
                    comment:  "An error message indicating there was an unexpected error with the payment"
                )
                .font(.headline)
                .foregroundColor(Color.red)

                Spacer()
            }
        }
    }
}

struct SwishPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        // prompt
        let promptViewModel = Preview.makeSwishPaymentViewModel()
        SwishPaymentView(viewModel: promptViewModel)
            .previewDisplayName("prompt")
        
        // creatingPaymentRequest
        let creatingPaymentRequestViewModel = Preview.makeSwishPaymentViewModel(
            state: .creatingPaymentRequest(selected: .swishApp)
        )
        SwishPaymentView(viewModel: creatingPaymentRequestViewModel)
            .previewDisplayName("creatingPaymentRequest")
        
        // waitingForPaymentRequest
        let waitingForPaymentRequestViewModel = Preview.makeSwishPaymentViewModel(
            state: .waitingForPaymentRequest(selected: .swishApp)
        )
        SwishPaymentView(viewModel: waitingForPaymentRequestViewModel)
            .previewDisplayName("waitingForPaymentRequest")
        
        // waitingForPayment
        let waitingForPaymentViewModel = Preview.makeSwishPaymentViewModel(state: .waitingForPayment)
        SwishPaymentView(viewModel: waitingForPaymentViewModel)
            .previewDisplayName("waitingForPayment")
        
        // paymentRequestInitialized (app)
        let paymentRequestInitializedAppViewModel = Preview.makeSwishPaymentViewModel(
            state: .paymentRequestInitialized(selected: .swishApp)
        )
        SwishPaymentView(viewModel: paymentRequestInitializedAppViewModel)
            .previewDisplayName("paymentRequestInitialized (app)")

        // paymentRequestInitialized (qr)
        let paymentRequestInitializedQrViewModel = Preview.makeSwishPaymentViewModel(
            state: .paymentRequestInitialized(selected: .qrCode)
        )
        SwishPaymentView(viewModel: paymentRequestInitializedQrViewModel)
            .previewDisplayName("paymentRequestInitialized (qr)")
        
        // paymentRequestInitialized (phone)
        let paymentRequestInitializedPhoneViewModel = Preview.makeSwishPaymentViewModel(
            state: .paymentRequestInitialized(selected: .phoneNumber)
        )
        SwishPaymentView(viewModel: paymentRequestInitializedPhoneViewModel)
            .previewDisplayName("paymentRequestInitialized (phone)")
        
        // paymentRejected
        let paymentRejectedViewModel = Preview.makeSwishPaymentViewModel(state: .paymentRejected)
        SwishPaymentView(viewModel: paymentRejectedViewModel)
            .previewDisplayName("paymentRejected")
        
        // paymentCompleted
        let paymentCompletedViewModel = Preview.makeSwishPaymentViewModel(state: .paymentCompleted)
        SwishPaymentView(viewModel: paymentCompletedViewModel)
            .previewDisplayName("paymentCompleted")
    }
}
