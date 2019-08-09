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
    
    func testLabelsForEventsWithNoPayloads() {
        let event = MockEvent.noPayload
        XCTAssertEqual(event.label, "noPayload")
    }
    
    func testLabelsForEventsWithPayloads() {
        let event = MockEvent.withNamedPayload(payload: "David Bowie")
        XCTAssertEqual(event.label, "withNamedPayload")
    }
    
    func testLabelsForOverloading() {
        let event = MockEvent.overload(str: "10")
        let overloading = MockEvent.overload(int: 10)
        XCTAssertEqual(event.label, "overload")
        XCTAssertEqual(overloading.label, "overload")
    }
    
    func testLabelsForEventsWithAnonymousPayloads() {
        let event = MockEvent.withAnonymousPayload("David Bowie")
        XCTAssertEqual(event.label, "withAnonymousPayload")
    }
    
    func testLabelsForEventsWithBlocks() {
        let event = MockBlockEvent.withBlock(block: { print($0) })
        XCTAssertEqual(event.label, "withBlock")
    }
    
    func testLabelsForEventsWithAnonymousBlocks() {
        let event = MockBlockEvent.withUnnamedBlock { print($0) }
        XCTAssertEqual(event.label, "withUnnamedBlock")
    }
    
    func testLabelsForEventsWithMixBlocks() {
        let event = MockBlockEvent.withMixBlock("David Bowie", block: { print($0) })
        XCTAssertEqual(event.label, "withMixBlock")
    }
    
    func testLabelsForEventsWithAnonymousMixBlocks() {
        let event = MockBlockEvent.withUnnamedMixBlock("David Bowie") { print($0) }
        XCTAssertEqual(event.label, "withUnnamedMixBlock")
    }
    
    func testLabelsForEventsWithNamedMixBlocks() {
        let event = MockBlockEvent.withNamedMixBlock(name: "David Bowie", block: { print($0) })
        XCTAssertEqual(event.label, "withNamedMixBlock")
    }
    
    func testThatItCanMatchNoPayloadEvents() {
        let event = MockEvent.noPayload
        XCTAssert(event.matches(event: MockEvent.noPayload))
    }
    
    func testThatItCanFailMatchingNoPayloadEvents() {
        let event = MockEvent.noPayload
        XCTAssertFalse(event.matches(event: MockEvent.anotherWithoutPayload))
    }
    
    func testThatItCanMatchEvents() {
        let event = MockEvent.withAnonymousPayload("David Bowie")
        XCTAssert(event.matches(pattern: MockEvent.withAnonymousPayload))
    }
    
    func testThatItCanMatchEventsWithBlocks() {
        let event = MockBlockEvent.withBlock(block: { print($0) })
        XCTAssert(event.matches(pattern: MockBlockEvent.withBlock))
    }
    
    func testThatItCanMatchEventsWithAnonymousBlocks() {
        let event = MockBlockEvent.withUnnamedBlock { print($0) }
        XCTAssert(event.matches(pattern: MockBlockEvent.withUnnamedBlock))
    }
    
    func testThatItCanMatchEventsWithMixBlocks() {
        let event = MockBlockEvent.withMixBlock("David Bowie", block: { print($0) })
        XCTAssert(event.matches(pattern: MockBlockEvent.withMixBlock))
    }
    
    func testThatItCanMatchEventsWithAnonymousMixBlocks() {
        let event = MockBlockEvent.withUnnamedMixBlock("David Bowie") { print($0) }
        XCTAssert(event.matches(pattern: MockBlockEvent.withUnnamedMixBlock))
    }
    
    func testThatItCanMatchEventsWithNamedMixBlocks() {
        let event = MockBlockEvent.withNamedMixBlock(name: "David Bowie", block: { print($0) })
        XCTAssert(event.matches(pattern: MockBlockEvent.withNamedMixBlock))
    }
    
    func testThatItCanFailMatchingEvents() {
        let event = MockEvent.withAnonymousPayload("David Bowie")
        XCTAssertFalse(event.matches(pattern: MockEvent.withNamedPayload))
    }
    
    func testThatItCanFailMatchingEventsWithBlocks() {
        let event = MockBlockEvent.withBlock(block: { print($0) })
        XCTAssertFalse(event.matches(pattern: MockBlockEvent.withUnnamedBlock))
    }
    
    func testThatItCanFailMatchingEventsWithAnonymousBlocks() {
        let event = MockBlockEvent.withUnnamedBlock { print($0) }
        XCTAssertFalse(event.matches(pattern: MockBlockEvent.withBlock))
    }
    
    func testThatItCanFailMatchingEventsWithMixBlocks() {
        let event = MockBlockEvent.withMixBlock("David Bowie", block: { print($0) })
        XCTAssertFalse(event.matches(pattern: MockBlockEvent.withUnnamedMixBlock))
    }
    
    func testThatItCanFailMatchingEventsWithAnonymousMixBlocks() {
        let event = MockBlockEvent.withUnnamedMixBlock("David Bowie") { print($0) }
        XCTAssertFalse(event.matches(pattern: MockBlockEvent.withMixBlock))
    }
    
    func testThatItCanFailMatchingEventsWithNamedMixBlocks() {
        let event = MockBlockEvent.withNamedMixBlock(name: "David Bowie", block: { print($0) })
        XCTAssertFalse(event.matches(pattern: MockBlockEvent.withMixBlock))
    }
    
    func testThatItCanExtractPayload() {
        let expectedPayload = "David Bowie"
        let event = MockEvent.withAnonymousPayload(expectedPayload)
        XCTAssertEqual(event.extractPayload(), expectedPayload)
    }
    
    func testThatItCanExtractPayloadOverloading() {
        let expectedPayload = "David Bowie"
        let event = MockEvent.overload(str: expectedPayload)
        XCTAssertEqual(event.extractPayload(), expectedPayload)
    }
    
    func testThatItCanExtractPayloadOverloaded() {
        let expectedPayload = 10
        let event = MockEvent.overload(int: expectedPayload)
        XCTAssertEqual(event.extractPayload(), expectedPayload)
    }
    
    func testThatItCannotExtractPayload() {
        let event = MockEvent.noPayload
        XCTAssertNil(event.extractPayload())
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
        XCTAssertEqual(event.extractPayload(), expectedPayload)
    }
    
    func testThatItCanCaptureAnonymousPayloadEvents() {
        let scheduler = TestScheduler(initialClock: 0)
        let events = scheduler.createHotObservable([
            .next(100, MockEvent.withAnonymousPayload("100")),
            .next(200, MockEvent.withAnonymousPayload("200")),
            .next(300, MockEvent.withNamedPayload(payload: "100")),
            .next(400, MockEvent.withAnonymousPayload("400")),
            .next(300, MockEvent.noPayload)
        ])
        let results = scheduler.createObserver(String.self)
        
        events.capture(event: MockEvent.withAnonymousPayload)
            .subscribe(results)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expected: [Recorded<Event<String>>] = [
            .next(100, "100"),
            .next(200, "200"),
            .next(400, "400")
        ]
        
        XCTAssertEqual(results.events, expected)
    }
    
    func testThatItCanCaptureNamedPayloadEvents() {
        let scheduler = TestScheduler(initialClock: 0)
        let events = scheduler.createHotObservable([
            .next(100, MockEvent.withNamedPayload(payload: "100")),
            .next(200, MockEvent.withAnonymousPayload("200")),
            .next(300, MockEvent.withNamedPayload(payload: "100")),
            .next(400, MockEvent.withAnonymousPayload("400")),
            .next(300, MockEvent.noPayload)
        ])
        let results = scheduler.createObserver(String.self)
        
        events.capture(event: MockEvent.withNamedPayload)
            .subscribe(results)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expected: [Recorded<Event<String>>] = [
            .next(100, "100"),
            .next(300, "100")
        ]
        
        XCTAssertEqual(results.events, expected)
    }
    
    func testThatItCanCaptureNoPayloadEvents() {
        let scheduler = TestScheduler(initialClock: 0)
        let events = scheduler.createHotObservable([
            .next(100, MockEvent.noPayload),
            .next(200, MockEvent.noPayload),
            .next(300, MockEvent.withNamedPayload(payload: "100")),
            .next(400, MockEvent.withAnonymousPayload("400")),
            .next(300, MockEvent.noPayload)
        ])
        let results = scheduler.createObserver(String.self)
        
        events.capture(event: MockEvent.noPayload)
            .map { _ in "" }
            .subscribe(results)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expected: [Recorded<Event<String>>] = [
            .next(100, ""),
            .next(200, ""),
            .next(300, "")
        ]
        
        XCTAssertEqual(results.events, expected)
    }
    
    func testItCanExcludeNoPayloadEvents() {
        let scheduler = TestScheduler(initialClock: 0)
        let events: TestableObservable<EventProtocol> = scheduler.createHotObservable([
            .next(100, MockEvent.noPayload),
            .next(200, MockEvent.noPayload),
            .next(300, MockEvent.withNamedPayload(payload: "100")),
            .next(400, MockEvent.withAnonymousPayload("400")),
            .next(300, MockEvent.noPayload)
        ])
        let results = scheduler.createObserver(MockEvent.self)
        
        events.exclude(event: MockEvent.noPayload)
            .subscribe(results)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expected: [Recorded<Event<MockEvent>>] = [
            .next(300, .withNamedPayload(payload: "100")),
            .next(400, .withAnonymousPayload("400"))
        ]
        
        XCTAssertEqual(results.events, expected)
    }
    
    func testItCanExcludeWithPayloadEvents() {
        let scheduler = TestScheduler(initialClock: 0)
        let events: TestableObservable<EventProtocol> = scheduler.createHotObservable([
            .next(100, MockEvent.noPayload),
            .next(200, MockEvent.noPayload),
            .next(300, MockEvent.withNamedPayload(payload: "100")),
            .next(400, MockEvent.withAnonymousPayload("400")),
            .next(500, MockEvent.noPayload)
        ])
        let results = scheduler.createObserver(MockEvent.self)
        
        events.exclude(event: MockEvent.withNamedPayload)
            .subscribe(results)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expected: [Recorded<Event<MockEvent>>] = [
            .next(100, MockEvent.noPayload),
            .next(200, MockEvent.noPayload),
            .next(400, .withAnonymousPayload("400")),
            .next(500, MockEvent.noPayload)
        ]
        
        XCTAssertEqual(results.events, expected)
    }
}
