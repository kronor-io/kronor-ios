//
//  ApplePaySession.swift
//  kronor-ios
//

import Foundation
import PassKit
import KronorCdeApi

/// The data extracted from an authorized `PKPayment`, in a `Sendable`
/// form that can cross from the PassKit delegate to the view model.
struct AuthorizedApplePayPayment: Sendable {
    let paymentData: Data
    let transactionIdentifier: String
    let displayName: String?
    let network: String?
    let methodType: PKPaymentMethodType

    init(payment: PKPayment) {
        self.paymentData = payment.token.paymentData
        self.transactionIdentifier = payment.token.transactionIdentifier
        self.displayName = payment.token.paymentMethod.displayName
        self.network = payment.token.paymentMethod.network?.rawValue
        self.methodType = payment.token.paymentMethod.type
    }
}

/// The JSON structure of `PKPaymentToken.paymentData`. See
/// https://developer.apple.com/documentation/PassKit/payment-token-format-reference
private struct ApplePayPaymentData: Decodable {
    struct Header: Decodable {
        let applicationData: String?
        let ephemeralPublicKey: String?
        let publicKeyHash: String?
        let transactionId: String?
        let wrappedKey: String?
    }

    let data: String
    let header: Header
    let signature: String
    let version: String
}

extension AuthorizedApplePayPayment {
    /// Maps the authorized payment to the CDE `ApplePayPaymentTokenInput`.
    func tokenInput() throws -> KronorCdeApi.ApplePayPaymentTokenInput {
        let paymentData = try JSONDecoder().decode(ApplePayPaymentData.self, from: self.paymentData)

        let methodType: GraphQLNullable<GraphQLEnum<KronorCdeApi.ApplePayPaymentMethodTypeEnum>> =
            switch self.methodType {
            case .credit: .some(.case(.credit))
            case .debit: .some(.case(.debit))
            case .prepaid: .some(.case(.prepaid))
            case .store: .some(.case(.store))
            default: .none
            }

        return KronorCdeApi.ApplePayPaymentTokenInput(
            paymentData: .some(KronorCdeApi.ApplePayPaymentDataInput(
                data: paymentData.data,
                header: KronorCdeApi.ApplePayPaymentHeaderInput(
                    applicationData: paymentData.header.applicationData.map { .some($0) } ?? .none,
                    ephemeralPublicKey: paymentData.header.ephemeralPublicKey.map { .some($0) } ?? .none,
                    publicKeyHash: paymentData.header.publicKeyHash.map { .some($0) } ?? .none,
                    transactionId: paymentData.header.transactionId.map { .some($0) } ?? .none,
                    wrappedKey: paymentData.header.wrappedKey.map { .some($0) } ?? .none
                ),
                signature: paymentData.signature,
                version: paymentData.version
            )),
            paymentMethod: KronorCdeApi.ApplePayPaymentMethodInput(
                displayName: self.displayName.map { .some($0) } ?? .none,
                network: self.network.map { .some($0) } ?? .none,
                type: methodType
            ),
            transactionIdentifier: .some(self.transactionIdentifier)
        )
    }
}

/// The outcome of a payment sheet session, reported after the sheet closes.
enum ApplePaySheetOutcome: Sendable {
    /// The customer authorized the payment and the CDE accepted the token.
    case authorized
    /// The customer authorized the payment but the token was rejected.
    case rejected
    /// The sheet was dismissed without a completed authorization.
    case dismissed
}

/// Bridges `PKPaymentAuthorizationController` delegate callbacks, which
/// arrive on an unspecified queue, to `Sendable` async closures.
final class ApplePaySessionDelegate: NSObject, PKPaymentAuthorizationControllerDelegate, @unchecked Sendable {
    private let onAuthorize: @Sendable (AuthorizedApplePayPayment) async -> Bool
    private let onFinish: @Sendable (ApplePaySheetOutcome) async -> Void

    /// The authorization runs on a Swift concurrency executor while `didFinish`
    /// arrives on PassKit's callback queue, so the shared outcome needs a lock.
    private let lock = NSLock()
    private var outcome: ApplePaySheetOutcome = .dismissed

    private func setOutcome(_ outcome: ApplePaySheetOutcome) {
        lock.lock()
        defer { lock.unlock() }
        self.outcome = outcome
    }

    private func currentOutcome() -> ApplePaySheetOutcome {
        lock.lock()
        defer { lock.unlock() }
        return outcome
    }

    init(
        onAuthorize: @escaping @Sendable (AuthorizedApplePayPayment) async -> Bool,
        onFinish: @escaping @Sendable (ApplePaySheetOutcome) async -> Void
    ) {
        self.onAuthorize = onAuthorize
        self.onFinish = onFinish
    }

    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        let authorized = AuthorizedApplePayPayment(payment: payment)
        let accepted = await onAuthorize(authorized)
        setOutcome(accepted ? .authorized : .rejected)
        return PKPaymentAuthorizationResult(status: accepted ? .success : .failure, errors: nil)
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        let outcome = currentOutcome()
        let onFinish = self.onFinish
        controller.dismiss {
            Task {
                await onFinish(outcome)
            }
        }
    }
}
