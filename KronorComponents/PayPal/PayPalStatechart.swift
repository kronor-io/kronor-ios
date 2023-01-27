//
//  PayPalStatechart.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-26.
//

import Foundation
import StateMachine
import KronorApi

final class PayPalStatechart : StateMachineBuilder {
    
    enum State : Equatable  {
        case initializing
        case paymentRequestInitialized
        case waitingForPayment
        case paymentRejected
        case paymentCompleted
        case errored (error: KronorApi.KronorError)
    }
    
    enum Event : Equatable  {
        case initialize
        case paymentRequestCreated
        case nonceSent
        case paymentAuthorized
        case paymentRejected
        case cancel
        case retry
        case cancelFlow
        case error (error: KronorApi.KronorError)
    }
    
    enum SideEffect {
        case createPaymentRequest
        case initializeBraintreeSDK
        case cancelPaymentRequest
        case subscribeToPaymentStatus
        case notifyPaymentSuccess
        case notifyPaymentFailure
        case resetState
    }
    
    typealias PayPalStateMachine = StateMachine<State, Event, SideEffect>
    

    static func makeStateMachine() -> PayPalStateMachine {
        makeStateMachineWithInitialState(initial: .initializing)
    }
    
    static func makeStateMachineWithInitialState(initial: State) -> PayPalStateMachine {
        PayPalStateMachine {
            initialState(initial)
            
            state(.initializing) {
                on(.initialize) {
                    dontTransition(emit: .createPaymentRequest)
                }
                on(.paymentRequestCreated) {
                    transition(to: .paymentRequestInitialized, emit: .initializeBraintreeSDK)
                }
            }

            state(.paymentRequestInitialized) {
                on (.nonceSent) {
                    transition(to: .waitingForPayment, emit: .subscribeToPaymentStatus)
                }
                on (.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorApi.KronorError))
                }
                on(.cancel) {
                    transition(to: .paymentRejected, emit: .cancelPaymentRequest)
                }
            }

            state(.waitingForPayment) {
                on(.paymentAuthorized) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }
                on(.paymentRejected) {
                    transition(to: .paymentRejected)
                }
                on (.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorApi.KronorError))
                }
                on(.cancel) {
                    transition(to: .paymentRejected, emit: .cancelPaymentRequest)
                }
            }

            state(.paymentRejected) {
                on(.cancelFlow) {
                    dontTransition(emit: .notifyPaymentFailure)
                }
                on(.retry) {
                    transition(to: .initializing, emit: .resetState)
                }
            }
        }
    }
}

extension PayPalStatechart.State: StateMachineHashable  {
    enum HashableIdentifier {
        case initializing
        case paymentRequestInitialized
        case waitingForPayment
        case paymentRejected
        case paymentCompleted
        case errored
    }

    var hashableIdentifier: HashableIdentifier {
        switch self {
        case .initializing:
            return .initializing
        case .paymentRequestInitialized:
            return .paymentRequestInitialized
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

extension PayPalStatechart.Event: StateMachineHashable  {
    enum HashableIdentifier {
        case initialize
        case paymentRequestCreated
        case nonceSent
        case paymentAuthorized
        case paymentRejected
        case cancel
        case retry
        case cancelFlow
        case error
    }

    var hashableIdentifier: HashableIdentifier {
        switch self {
        case .initialize:
            return .initialize
        case .paymentRequestCreated:
            return .paymentRequestCreated
        case .nonceSent:
            return .nonceSent
        case .paymentAuthorized:
            return .paymentAuthorized
        case .paymentRejected:
            return .paymentRejected
        case .error:
            return .error
        case .cancel:
            return .cancel
        case .cancelFlow:
            return .cancelFlow
        case .retry:
            return .retry
        }
    }

    var associatedValue: Any {
        switch self {
        case let .error(value):
            return value
        default:
            return ()
        }
    }
}
