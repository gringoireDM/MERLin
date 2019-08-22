//
//  EventsTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 09/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import RxSwift
import RxTest
import XCTest

class EventsTests: XCTestCase {
    var disposeBag: DisposeBag!
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        super.tearDown()
    }
    
    func testThatItCanEquateAnyEvent() {
        let event = AnyEvent(base: MockEvent.noPayload)
        XCTAssert(event.matches(event: MockEvent.noPayload))
    }
    
    func testThatItCanEquateAnyEventWithPayload() {
        let event = AnyEvent(base: MockEvent.withAnonymousPayload("David Bowie"))
        XCTAssert(event.matches(pattern: MockEvent.withAnonymousPayload))
    }
    
    func testThatItCanFailEquatingAnyEvent() {
        let event = AnyEvent(base: MockEvent.noPayload)
        XCTAssertFalse(event.matches(event: MockEvent.anotherWithoutPayload))
    }
    
    func testThatItCanFailEquatingAnyEventWithPayload() {
        let event = AnyEvent(base: MockEvent.withAnonymousPayload("David Bowie"))
        XCTAssertFalse(event.matches(pattern: MockEvent.withNamedPayload))
    }
    
    func testItCanExtractAnyEventPayload() {
        let expectedPayload = "David Bowie"
        let event = AnyEvent(base: MockEvent.withAnonymousPayload(expectedPayload))
        XCTAssertEqual(event.associatedValue(), expectedPayload)
    }
}
