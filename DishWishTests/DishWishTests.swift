//
//  DishWishTests.swift
//  DishWishTests
//
//  Created by Choi Siu Lun Alan on 11/4/2025.
//

import XCTest

final class DishWishTests: XCTestCase {

    func testFetchToken() async throws {
        let helper = FatSecretApiHelper(
            clientId: "26bba508fac24033a05000c00485d5ab",
            clientSecret: "67873fdd295340778678a5da71f276d1"
        )

        let tokenExpectation = expectation(description: "Token fetched")

        helper.fetchAccessToken { token in
            XCTAssertNotNil(token, "Access token should not be nil")
            print("Fetched token: \(token ?? "nil")")
            tokenExpectation.fulfill()
        }

        await fulfillment(of: [tokenExpectation], timeout: 5)
    }
}
