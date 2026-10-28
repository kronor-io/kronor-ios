//
//  P24ChannelOverrideTests.swift
//

import XCTest
@testable import KronorComponents

/// The channel override reaches the hosted page only as a query item on the
/// session URL, so these pin down exactly what is sent.
final class P24ChannelOverrideTests: XCTestCase {

    func testSendsTheChannelOverride() {
        XCTAssertEqual(
            P24Component.queryItems(channelOverride: .blik),
            [URLQueryItem(name: "channelOverride", value: "BLIK")]
        )
    }

    func testSendsAChannelTheSDKDoesNotKnowAbout() {
        XCTAssertEqual(
            P24Component.queryItems(channelOverride: P24PaymentChannel(rawValue: "CARDS")),
            [URLQueryItem(name: "channelOverride", value: "CARDS")]
        )
    }

    /// Without an override the hosted page uses the merchant's channels, so
    /// nothing may be added to the URL.
    func testSendsNothingWithoutAnOverride() {
        XCTAssertEqual(P24Component.queryItems(channelOverride: nil), [])
    }

    /// An empty value would reach GraphQL as an invalid enum label and fail the
    /// payment, so it counts as no override.
    func testTreatsAnEmptyChannelAsNoOverride() {
        XCTAssertEqual(P24Component.queryItems(channelOverride: P24PaymentChannel(rawValue: "")), [])
    }
}
