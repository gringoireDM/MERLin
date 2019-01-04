//
//  DeeplinkableTests.swift
//  DeeplinkableTests
//
//  Created by Giuseppe Lanza on 06/03/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import XCTest

class DeeplinkableTests: XCTestCase {
    func testThatMockIsIncludedInAvailableDeeplinkHandlers() {
        let mockType = DeeplinkMatcher.typedAvailableDeeplinkHandlers.values.filter { (type) -> Bool in
            return type == MockDeeplinkable.self
        }
        XCTAssertEqual(mockType.count, MockDeeplinkable.deeplinkRegexes()!.count)
    }
    
    func testThatMockRegularExpressionsAreInAvailableDeeplinkHandlers() {
        let regExp = DeeplinkMatcher.typedAvailableDeeplinkHandlers.keys.filter { (regEx) -> Bool in
            return DeeplinkMatcher.typedAvailableDeeplinkHandlers[regEx] == MockDeeplinkable.self
        }
        
        XCTAssertEqual(Set(regExp), Set(MockDeeplinkable.deeplinkRegexes()!))
    }
    
    func testDeeplinkRemainder() {
        let deeplink = "test://mock/product/1234"
        let expectedRemainder = "test://product/1234"
        
        let remainder = MockDeeplinkable.remainderDeeplink(fromDeeplink: deeplink)
        XCTAssertNotNil(remainder)
        
        XCTAssertEqual(remainder, expectedRemainder)
    }
    
    func testDeeplinkRemainderWithMatchingGroup() {
        let deeplink = "test://mock/2341234/product/1234"
        let expectedRemainder = "test://product/1234"
        
        let remainder = MockDeeplinkable.remainderDeeplink(fromDeeplink: deeplink)
        XCTAssertNotNil(remainder)
        
        XCTAssertEqual(remainder, expectedRemainder)
    }
    
    func testNoRemainder() {
        let deeplink = "test://mock/"
        let remainder = MockDeeplinkable.remainderDeeplink(fromDeeplink: deeplink)
        
        XCTAssertNil(remainder)
    }
    
    func testThatDefaultImplementationCanBeAccessedByDeeplinkableType() {
        let type: Deeplinkable.Type = MockDeeplinkable.self
        
        let deeplink = "test://mock/2341234/product/1234"
        let expectedRemainder = "test://product/1234"
        
        let remainder = type.remainderDeeplink(fromDeeplink: deeplink)
        XCTAssertNotNil(remainder)
        
        XCTAssertEqual(remainder, expectedRemainder)
    }
    
    func testThatItCanExaustRemainders() {
        let deeplink = "test://mock/2341234/product/1234"
        let expectedRemainder = "test://product/1234"
        
        let remainder = MockDeeplinkable.remainderDeeplink(fromDeeplink: deeplink)
        XCTAssertNotNil(remainder)
        XCTAssertEqual(remainder, expectedRemainder)
        
        guard let newDeepLink = remainder else {
            XCTFail("No remainder. \(expectedRemainder) was expected.")
            return
        }
        let secondRemainder = MockDeeplinkable.remainderDeeplink(fromDeeplink: newDeepLink)
        XCTAssertNil(secondRemainder)
    }
}
