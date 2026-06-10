//
//  AuthSessionView.swift
//  KronorComponents
//
//  Created by Tim Kofoed on 23/03/2026.
//

import SwiftUI
import AuthenticationServices

struct AuthSessionViewRepresentable: UIViewControllerRepresentable {

    typealias UIViewControllerType = AuthSessionViewController

    private let url: URL
    private let callbackScheme: String
    private let onComplete: (URL?) -> Void
    private let onCancel: () -> Void

    init(
        url: URL,
        callbackScheme: String,
        onComplete: @escaping (URL?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.url = url
        self.callbackScheme = callbackScheme
        self.onComplete = onComplete
        self.onCancel = onCancel
    }

    func makeUIViewController(context: Context) -> AuthSessionViewController {
        AuthSessionViewController(
            url: url,
            callbackScheme: callbackScheme,
            onComplete: onComplete,
            onCancel: onCancel
        )
    }

    func updateUIViewController(_ uiViewController: AuthSessionViewController, context: Context) { }
}

final class AuthSessionViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {

    private let url: URL
    private let callbackScheme: String
    private let onComplete: (URL?) -> Void
    private let onCancel: () -> Void
    private var authSession: ASWebAuthenticationSession?
    private var hasStarted = false

    init(
        url: URL,
        callbackScheme: String,
        onComplete: @escaping (URL?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.url = url
        self.callbackScheme = callbackScheme
        self.onComplete = onComplete
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !hasStarted else { return }
        hasStarted = true
        startAuthSession()
    }

    private func startAuthSession() {
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackScheme
        ) { [onComplete, onCancel] callbackURL, error in
            if let sessionError = error as? ASWebAuthenticationSessionError,
               sessionError.code == .canceledLogin {
                onCancel()
                return
            }

            if error != nil {
                onCancel()
                return
            }

            onComplete(callbackURL)
        }

        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = self
        authSession = session

        let didStart = session.start()
        if !didStart {
            onCancel()
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}
