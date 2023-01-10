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
                    Text("Creating secure Swish transaction")
                        .font(.subheadline)
                    Spacer()
                }
            }

            
        case .paymentRequestInitialized(.swishApp):
            return SwishWrapperView {
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                    Text("Opening the swish app")
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
                        Text("Generating QR code")
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
                    Text("You can pay with the Swish app now")
                        .font(.headline)
                        
                    Spacer()
                }
            }


        case .waitingForPayment:
            return SwishWrapperView {
                HStack {
                    Spacer()
                    Image(systemName: "hourglass.circle")
                    Text("Completing payment")
                        .font(.subheadline)
                    Spacer()
                }
            }


        case .paymentRejected:
            return SwishWrapperView {
                SwishPaymentRejectedView(viewModel: viewModel)
            }

            
        case .paymentCompleted:
            return SwishWrapperView {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                        
                    Text("Payment completed")
                        .font(.headline)
                        .foregroundColor(Color.green)
                        
                    Spacer()
                }
            }

            
        case .errored(let error):
            return SwishWrapperView {
                Text(String("errored: \(error)"))
            }
        }
    }
}

struct SwishPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        
        // prompt
        let machine = SwishStatechart.makeStateMachine()
        let viewModel = SwishPaymentViewModel(
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
