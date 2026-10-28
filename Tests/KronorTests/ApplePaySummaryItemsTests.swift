//
//  ApplePaySummaryItemsTests.swift
//

import XCTest
import Apollo
import ApolloAPI
import PassKit
@testable import KronorApi
@testable import KronorComponents

@MainActor
final class ApplePaySummaryItemsTests: XCTestCase {

    private static func orderLines(_ lines: [[String: Any?]]) async throws -> [ApplePayOrderLine] {
        let data = try await KronorApi.PaymentSessionOrderLinesQuery.Data(data: [
            "paymentSessions": [[
                "__typename": "PaymentSession",
                "orderLines": lines.map { line in
                    line.merging(["__typename": "PaymentSessionOrderLine"]) { $1 }
                        .mapValues { $0 ?? NSNull() }
                },
            ]],
        ])
        return data.paymentSessions.first?.orderLines ?? []
    }

    private static func summary(_ items: [PKPaymentSummaryItem]) -> [String] {
        items.map { "\($0.label) \($0.amount.stringValue)" }
    }

    func testTotalOnlyWithoutOrderLines() {
        let items = ApplePayPaymentViewModel.paymentSummaryItems(
            orderLines: [],
            total: "10056",
            currency: .case(.sek),
            merchantName: "Merchant"
        )

        XCTAssertEqual(Self.summary(items), ["Merchant 100.56"])
    }

    func testOrderLinesPrecedeTheTotal() async throws {
        let items = ApplePayPaymentViewModel.paymentSummaryItems(
            orderLines: try await Self.orderLines([
                ["name": "First item", "totalAmount": "10056"],
                ["name": "Second item", "totalAmount": "20000"],
            ]),
            total: "30056",
            currency: .case(.sek),
            merchantName: "Merchant"
        )

        XCTAssertEqual(Self.summary(items), [
            "First item 100.56",
            "Second item 200",
            "Merchant 300.56",
        ])
    }

    func testIncompleteOrderLinesAreLeftOut() async throws {
        let items = ApplePayPaymentViewModel.paymentSummaryItems(
            orderLines: try await Self.orderLines([
                ["name": nil, "totalAmount": "100"],
                ["name": "No amount", "totalAmount": nil],
                ["name": "Item", "totalAmount": "500"],
            ]),
            total: "500",
            currency: .case(.isk),
            merchantName: "Merchant"
        )

        XCTAssertEqual(Self.summary(items), ["Item 500", "Merchant 500"])
    }
}
