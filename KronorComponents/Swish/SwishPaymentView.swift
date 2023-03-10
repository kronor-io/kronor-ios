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
        switch viewModel.state {
        case .promptingMethod:
            return SwishWrapperView {
                SwishPromptMethodView(viewModel: viewModel)
            }
            
            
        case .insertingPhoneNumber:
            return SwishWrapperView {
                SwishInsertPhoneNumberView(viewModel: viewModel)
            }

            
        case .creatingPaymentRequest, .waitingForPaymentRequest:
            return SwishWrapperView {
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
            }

            
        case .paymentRequestInitialized(.swishApp):
            return SwishWrapperView {
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
            }

            
        case .paymentRequestInitialized(.qrCode):
            return SwishWrapperView {
                if let qrCode = viewModel.qrCode {
                    return AnyView(SwishQRView(qrCode: qrCode))
                } else {
                    return HStack {
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
            }

            
        case .paymentRequestInitialized(.phoneNumber):
            return SwishWrapperView {
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
            }


        case .waitingForPayment:
            return SwishWrapperView {
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
            }


        case .paymentRejected:
            return SwishWrapperView {
                PaymentRejectedView(viewModel: self.viewModel)
            }

            
        case .paymentCompleted:
            return SwishWrapperView {
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
            }

            
        case .errored(_):
            return SwishWrapperView {
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
}

struct SwishPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        
        // prompt
        let machine = SwishStatechart.makeStateMachine()
        let viewModel = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel)
            .previewDisplayName("prompt")
        
        // creatingPaymentRequest
        let machine2 = SwishStatechart.makeStateMachineWithInitialState(initial: .creatingPaymentRequest(selected: .swishApp))
        let viewModel2 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine2,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel2)
            .previewDisplayName("creatingPaymentRequest")
        
        // creatingPaymentRequest
        let machine3 = SwishStatechart.makeStateMachineWithInitialState(initial: .waitingForPaymentRequest(selected: .swishApp))
        let viewModel3 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine3,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel3)
            .previewDisplayName("waitingForPaymentRequest")
        
        // waitingForPayment
        let machine4 = SwishStatechart.makeStateMachineWithInitialState(initial: .waitingForPayment)
        let viewModel4 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine4,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel4)
            .previewDisplayName("waitingForPayment")
        
        // paymentRequestInitialized (app)
        let machine5 = SwishStatechart.makeStateMachineWithInitialState(initial: .paymentRequestInitialized(selected: .swishApp))
        let viewModel5 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine5,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel5)
            .previewDisplayName("paymentRequestInitialized (app)")

        // paymentRequestInitialized (qr)
        let machine6 = SwishStatechart.makeStateMachineWithInitialState(initial: .paymentRequestInitialized(selected: .qrCode))
        let viewModel6 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine6,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel6)
            .previewDisplayName("paymentRequestInitialized (qr)")
        
        // paymentRequestInitialized (phone)
        let machine7 = SwishStatechart.makeStateMachineWithInitialState(initial: .paymentRequestInitialized(selected: .phoneNumber))
        let viewModel7 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine7,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel7)
            .previewDisplayName("paymentRequestInitialized (phone)")
        
        // paymentRejected
        let machine8 = SwishStatechart.makeStateMachineWithInitialState(initial: .paymentRejected)
        let viewModel8 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine8,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel8)
            .previewDisplayName("paymentRejected")
        
        // paymentCompleted
        let machine9 = SwishStatechart.makeStateMachineWithInitialState(initial: .paymentCompleted)
        let viewModel9 = SwishPaymentViewModel(
            env: .sandbox,
            sessionToken: "dummy",
            stateMachine: machine9,
            returnURL: URL(string: "io.kronortest://")!,
            onPaymentFailure: {},
            onPaymentSuccess: {paymentId in }
        )
        SwishPaymentView(viewModel: viewModel9)
            .previewDisplayName("paymentCompleted")
    }
}
