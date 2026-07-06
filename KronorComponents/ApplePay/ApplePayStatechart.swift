//
//  ApplePayStatechart.swift
//  kronor-ios
//

import Foundation
import StateMachine
import KronorApi

final class ApplePayStatechart: StateMachineBuilder {

    enum State: Equatable, Sendable {
        case initializing
        case notAvailable
        case creatingPaymentRequest
        case waitingForPaymentRequest
        case paymentReady
        case authorizing
        case waitingForSheetDismissal
        case waitingForPayment
        case paymentRejected
        case paymentCompleted
        case errored (error: KronorApi.KronorError)
    }

    enum Event: Equatable, Sendable {
        case initialize
        case applePayUnavailable
        case paymentRequestCreated (waitToken: String)
        case paymentRequestInitialized
        case payButtonTapped
        case sheetDismissed
        case tokenAuthorized
        case paymentAuthorized
        case paymentRejected
        case retry
        case cancelFlow
        case error (error: KronorApi.KronorError)
    }

    enum SideEffect: Sendable {
        case createPaymentRequest
        case subscribeToPaymentStatus (waitToken: String)
        case presentPaymentSheet
        case notifyPaymentSuccess
        case cancelAndNotifyFailure
        case resetState
    }

    typealias ApplePayStateMachine = StateMachine<State, Event, SideEffect>

    static func makeStateMachine() -> ApplePayStateMachine {
        makeStateMachineWithInitialState(initial: .initializing)
    }

    static func makeStateMachineWithInitialState(initial: State) -> ApplePayStateMachine {
        ApplePayStateMachine {
            initialState(initial)

            state(.initializing) {
                on(.initialize) {
                    transition(to: .creatingPaymentRequest, emit: .createPaymentRequest)
                }

                on(.applePayUnavailable) {
                    transition(to: .notAvailable)
                }
            }

            state(.notAvailable) {
                on(.cancelFlow) {
                    dontTransition(emit: .cancelAndNotifyFailure)
                }
            }

            state(.creatingPaymentRequest) {
                // The initial payment request creation can be cancelled by SwiftUI
                // (the component's task is cancelled when the view disappears); a
                // repeated initialize retries it.
                on(.initialize) {
                    dontTransition(emit: .createPaymentRequest)
                }

                on(.paymentRequestCreated) {
                    guard case let .paymentRequestCreated(waitToken) = $1 else { return dontTransition() }

                    return transition(to: .waitingForPaymentRequest,
                                      emit: .subscribeToPaymentStatus(waitToken: waitToken))
                }

                on(.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorApi.KronorError))
                }
            }

            state(.waitingForPaymentRequest) {
                on(.paymentRequestInitialized) {
                    transition(to: .paymentReady)
                }

                on(.paymentRejected) {
                    transition(to: .paymentRejected)
                }

                on(.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorApi.KronorError))
                }
            }

            state(.paymentReady) {
                on(.payButtonTapped) {
                    transition(to: .authorizing, emit: .presentPaymentSheet)
                }

                on(.paymentAuthorized) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }

                on(.paymentRejected) {
                    transition(to: .paymentRejected)
                }

                on(.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorApi.KronorError))
                }
            }

            state(.authorizing) {
                on(.tokenAuthorized) {
                    transition(to: .waitingForPayment)
                }

                on(.sheetDismissed) {
                    transition(to: .paymentReady)
                }

                // The payment can be reported as paid while the payment sheet is
                // still on screen. Success is only reported to the merchant once
                // the sheet has closed, otherwise the merchant may tear down the
                // component while PassKit is still presenting.
                on(.paymentAuthorized) {
                    transition(to: .waitingForSheetDismissal)
                }

                on(.paymentRejected) {
                    transition(to: .paymentRejected)
                }

                on(.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorApi.KronorError))
                }
            }

            state(.waitingForSheetDismissal) {
                // The payment is already paid; whatever the sheet reports, the
                // backend outcome wins.
                on(.tokenAuthorized) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }

                on(.sheetDismissed) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }

                on(.paymentRejected) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }
            }

            state(.waitingForPayment) {
                on(.paymentAuthorized) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }

                on(.paymentRejected) {
                    transition(to: .paymentRejected)
                }

                on(.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorApi.KronorError))
                }
            }

            state(.paymentRejected) {
                on(.cancelFlow) {
                    dontTransition(emit: .cancelAndNotifyFailure)
                }

                on(.retry) {
                    transition(to: .initializing, emit: .resetState)
                }

                // A rejected sheet outcome can be contradicted by the backend:
                // e.g. the authorize call timed out client-side but the payment
                // went through. The customer was charged, so report success.
                on(.paymentAuthorized) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }
            }
        }
    }
}

extension ApplePayStatechart.State: StateMachineHashable {
    enum HashableIdentifier {
        case initializing
        case notAvailable
        case creatingPaymentRequest
        case waitingForPaymentRequest
        case paymentReady
        case authorizing
        case waitingForSheetDismissal
        case waitingForPayment
        case paymentRejected
        case paymentCompleted
        case errored
    }

    var hashableIdentifier: HashableIdentifier {
        switch self {
        case .initializing:
            return .initializing
        case .notAvailable:
            return .notAvailable
        case .creatingPaymentRequest:
            return .creatingPaymentRequest
        case .waitingForPaymentRequest:
            return .waitingForPaymentRequest
        case .paymentReady:
            return .paymentReady
        case .authorizing:
            return .authorizing
        case .waitingForSheetDismissal:
            return .waitingForSheetDismissal
        case .waitingForPayment:
            return .waitingForPayment
        case .paymentRejected:
            return .paymentRejected
        case .paymentCompleted:
            return .paymentCompleted
        case .errored:
            return .errored
        }
    }

    var associatedValue: Any {
        switch self {
        case let .errored(value):
            return value
        default:
            return ()
        }
    }
}

extension ApplePayStatechart.Event: StateMachineHashable {
    enum HashableIdentifier {
        case initialize
        case applePayUnavailable
        case paymentRequestCreated
        case paymentRequestInitialized
        case payButtonTapped
        case sheetDismissed
        case tokenAuthorized
        case paymentAuthorized
        case paymentRejected
        case retry
        case cancelFlow
        case error
    }

    var hashableIdentifier: HashableIdentifier {
        switch self {
        case .initialize:
            return .initialize
        case .applePayUnavailable:
            return .applePayUnavailable
        case .paymentRequestCreated:
            return .paymentRequestCreated
        case .paymentRequestInitialized:
            return .paymentRequestInitialized
        case .payButtonTapped:
            return .payButtonTapped
        case .sheetDismissed:
            return .sheetDismissed
        case .tokenAuthorized:
            return .tokenAuthorized
        case .paymentAuthorized:
            return .paymentAuthorized
        case .paymentRejected:
            return .paymentRejected
        case .retry:
            return .retry
        case .cancelFlow:
            return .cancelFlow
        case .error:
            return .error
        }
    }

    var associatedValue: Any {
        switch self {
        case let .paymentRequestCreated(value):
            return value
        case let .error(value):
            return value
        default:
            return ()
        }
    }
}
