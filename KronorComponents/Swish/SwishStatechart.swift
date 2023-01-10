//
//  Statechart.swift
//  kronor-ios
//
//  Created by lorenzo on 2023-01-04.
//

import Foundation
import StateMachine
import KronorApi

enum KronorError: Error, Equatable {
    static func == (lhs: KronorError, rhs: KronorError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError(_), .networkError(_)):
            return true
        case (.usageError(_), .usageError(_)):
            return true
        default:
            return false
        }
    }
    
    case networkError (error: Error)
    case usageError (error: KronorApi.APIError)
}

final class SwishStatechart : StateMachineBuilder {
    
    enum State : Equatable  {
        case promptingMethod 
        case insertingPhoneNumber
        case creatingPaymentRequest (selected: SelectedMethod)
        case waitingForPaymentRequest (selected: SelectedMethod)
        case paymentRequestInitialized (selected: SelectedMethod)
        case waitingForPayment
        case paymentRejected
        case paymentCompleted
        case errored (error: KronorError)
    }
    
    enum Event : Equatable  {
        case useSwishApp
        case usePhoneNumber
        case phoneNumberInserted (number: String)
        case useQR
        case paymentRequestCreated (waitToken: String)
        case paymentRequestInitialized
        case paymentAuthorized
        case paymentRejected
        case retry
        case cancelFlow
        case error (error: KronorError)
        case swishAppOpened
    }
    
    enum SideEffect {
        case createEcomPaymentRequest (phoneNumber: String)
        case createMcomPaymentRequest
        case cancelPaymentRequest
        case openSwishApp
        case subscribeToPaymentStatus (waitToken: String)
        case notifyPaymentSuccess
        case notifyPaymentFailure
        case resetState
    }
    
    enum SelectedMethod : Equatable {
        case swishApp
        case qrCode
        case phoneNumber
    }
    
    typealias SwishStateMachine = StateMachine<State, Event, SideEffect>
    

    static func makeStateMachine() -> SwishStateMachine {
        makeStateMachineWithInitialState(initial: .promptingMethod)
    }
    
    static func makeStateMachineWithInitialState(initial: State) -> SwishStateMachine {
        SwishStateMachine {
            initialState(initial)
            
            state(.promptingMethod) {
                
                on(.useSwishApp) {
                    transition(to: .creatingPaymentRequest(selected: .swishApp), emit: .createMcomPaymentRequest)
                }
                
                on(.useQR) {
                    transition(to: .creatingPaymentRequest(selected: .qrCode), emit: .createMcomPaymentRequest)
                }
                
                on(.usePhoneNumber) {
                    transition(to: .insertingPhoneNumber)
                }
            }
            
            state(.insertingPhoneNumber) {
                on(.phoneNumberInserted) {
                    guard case let .phoneNumberInserted(phoneNumber) = $1 else { return dontTransition() }
                    
                    return transition(to: .creatingPaymentRequest(selected: .phoneNumber), emit: .createEcomPaymentRequest(phoneNumber: phoneNumber))
                }
            }
            
            state(.creatingPaymentRequest) {
                
                on (.paymentRequestCreated) {
                    guard case let .creatingPaymentRequest(selected) = $0 else { return dontTransition() }
                    guard case let .paymentRequestCreated(waitToken) = $1 else { return dontTransition() }
                    
                    return transition(to: .waitingForPaymentRequest(selected: selected),
                                      emit: .subscribeToPaymentStatus(waitToken: waitToken))
                }

                on (.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorError))
                }
            }
            
            state(.waitingForPaymentRequest) {
                
                on(.paymentRequestInitialized) {
                    guard case let .waitingForPaymentRequest(selected) = $0 else { return dontTransition() }
                    
                    var sideEffect: SideEffect?
                    if case .swishApp = selected {
                        sideEffect = .openSwishApp
                    }
                    
                    return transition(to: .paymentRequestInitialized(selected: selected), emit: sideEffect)
                }

                on (.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorError))
                }
            }
            
            state(.paymentRequestInitialized) {
                on (.retry) {
                    transition(to: .promptingMethod, emit: .resetState)
                }
                
                on (.swishAppOpened) {
                    transition(to: .waitingForPayment)
                }

                on(.paymentAuthorized) {
                    transition(to: .paymentCompleted, emit: .notifyPaymentSuccess)
                }
                on(.paymentRejected) {
                    transition(to: .paymentRejected)
                }
                on (.error) {
                    transition(to: .errored(error: $1.associatedValue as! KronorError))
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
                    transition(to: .errored(error: $1.associatedValue as! KronorError))
                }
            }
            
            state(.paymentRejected) {
                on(.cancelFlow) {
                    dontTransition(emit: .notifyPaymentFailure)
                }
                
                on(.retry) {
                    transition(to: .promptingMethod, emit: .resetState)
                }
            }
        }
    }
}

extension SwishStatechart.State: StateMachineHashable  {
    enum HashableIdentifier {
        case promptingMethod
        case insertingPhoneNumber
        case displayingQR
        case creatingPaymentRequest
        case waitingForPaymentRequest
        case paymentRequestInitialized
        case waitingForPayment
        case paymentRejected
        case paymentCompleted
        case errored
    }
    
    var hashableIdentifier: HashableIdentifier {
        switch self {
        case .promptingMethod:
            return .promptingMethod
        case .insertingPhoneNumber:
            return .insertingPhoneNumber
        case .creatingPaymentRequest:
            return .creatingPaymentRequest
        case .waitingForPaymentRequest:
            return .waitingForPaymentRequest
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
        case let .waitingForPaymentRequest(value):
            return value
        case let .creatingPaymentRequest(value):
            return value
        case let .paymentRequestInitialized(value):
            return value
        case let .errored(value):
            return value
        default:
            return ()
        }
    }
}

extension SwishStatechart.Event: StateMachineHashable  {
    enum HashableIdentifier {
        case useSwishApp
        case usePhoneNumber
        case phoneNumberInserted
        case useQR
        case paymentRequestCreated
        case paymentRequestInitialized
        case paymentAuthorized
        case paymentRejected
        case error
        case retry
        case cancelFlow
        case swishAppOpened
    }
    
    var hashableIdentifier: HashableIdentifier {
        switch self {
        case .useSwishApp:
            return .useSwishApp
        case .usePhoneNumber:
            return .usePhoneNumber
        case .phoneNumberInserted:
            return .phoneNumberInserted
        case .useQR:
            return .useQR
        case .paymentRequestCreated:
            return .paymentRequestCreated
        case .paymentRequestInitialized:
            return .paymentRequestInitialized
        case .paymentAuthorized:
            return .paymentAuthorized
        case .paymentRejected:
            return .paymentRejected
        case .error:
            return .error
        case .retry:
            return .retry
        case .cancelFlow:
            return .cancelFlow
        case .swishAppOpened:
            return .swishAppOpened
        }
    }

    var associatedValue: Any {
        switch self {
        case let .error(value):
            return value
        case let .phoneNumberInserted(value):
            return value
        default:
            return ()
        }
    }
}
