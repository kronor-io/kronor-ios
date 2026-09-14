//
//  EmbeddedSiteWebViewTests.swift
//

import XCTest
@testable import KronorComponents

/// The embedded site's webview is where the customer actually pays: it starts
/// on the session URL and then navigates wherever the provider takes it
/// (PayPal, a bank). SwiftUI re-runs `updateUIView` on every body update, so
/// what that method decides to reload determines whether the customer keeps
/// their place or is thrown back to the start of the flow.
final class EmbeddedSiteWebViewTests: XCTestCase {

    /// The regression behind "PayPal is completely broken": the reload was
    /// decided by comparing the webview's current URL against the session URL.
    /// Once the customer had been handed off to PayPal those differ by design,
    /// so every body update reloaded the session page on top of the provider's
    /// — an endless loop back to the PayPal login screen.
    func testDoesNotReloadWhileTheAttemptIsUnderway() {
        XCTAssertFalse(SwiftUIWebView.shouldLoad(attempt: 1, loadedAttempt: 1))
    }

    /// A retry reuses the same session URL, so only the attempt distinguishes a
    /// fresh start from an ongoing one. If SwiftUI hands the previous attempt's
    /// webview to a new presentation, it has to be sent back to the site rather
    /// than left on the dead page.
    func testReloadsForANewAttempt() {
        XCTAssertTrue(SwiftUIWebView.shouldLoad(attempt: 2, loadedAttempt: 1))
    }

    func testLoadsWhenNothingHasBeenLoadedYet() {
        XCTAssertTrue(SwiftUIWebView.shouldLoad(attempt: 1, loadedAttempt: nil))
    }
}
