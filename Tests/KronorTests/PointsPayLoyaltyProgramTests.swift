//
//  PointsPayLoyaltyProgramTests.swift
//

import XCTest
@testable import KronorComponents

/// The loyalty programs reach the hosted page only as a query item on the
/// session URL, so these pin down exactly what is sent.
final class PointsPayLoyaltyProgramTests: XCTestCase {

    func testSendsASingleProgram() {
        XCTAssertEqual(
            PointsPayComponent.queryItems(loyaltyPrograms: ["SAS"]),
            [URLQueryItem(name: "loyaltyProgram", value: "SAS")]
        )
    }

    func testSendsTheProgramsInOrderOfPreference() {
        XCTAssertEqual(
            PointsPayComponent.queryItems(loyaltyPrograms: ["MAM", "SAS", "FLB"]),
            [URLQueryItem(name: "loyaltyProgram", value: "MAM,SAS,FLB")]
        )
    }

    /// The codes are the API's to validate, so ones the SDK has never heard of
    /// are sent as given.
    func testSendsAProgramTheSDKDoesNotKnowAbout() {
        XCTAssertEqual(
            PointsPayComponent.queryItems(loyaltyPrograms: ["SAS", "NEW"]),
            [URLQueryItem(name: "loyaltyProgram", value: "SAS,NEW")]
        )
    }

    /// Without programs the shopper picks one in Pointspay, so nothing may be
    /// added to the URL.
    func testSendsNothingWithoutPrograms() {
        XCTAssertEqual(PointsPayComponent.queryItems(loyaltyPrograms: []), [])
    }

    /// The API rejects empty entries such as `SAS,,FLB`, which would fail the
    /// payment, so blank codes are dropped.
    func testDropsBlankPrograms() {
        XCTAssertEqual(
            PointsPayComponent.queryItems(loyaltyPrograms: ["SAS", "", " ", "FLB"]),
            [URLQueryItem(name: "loyaltyProgram", value: "SAS,FLB")]
        )
        XCTAssertEqual(PointsPayComponent.queryItems(loyaltyPrograms: ["", " "]), [])
    }
}
