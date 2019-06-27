//
//  EventsListenerTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 21/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import XCTest

class EventsListenerTests: XCTestCase {
    var producer: AnyEventsProducer!
    
    override func setUp() {
        super.setUp()
        producer = MockProducer<MockEvent>()
    }
    
    override func tearDown() {
        producer = nil
        super.tearDown()
    }
    
    func testThatAListenerCanRegisterToASpecificEventsProducer() {
        let listener = MockEventsListener<MockEvent>()
        listener.listenEvents(from: producer)
        XCTAssertEqual(listener.registeredProducers.count, 1)
        XCTAssert(listener.registeredProducers.first === producer)
    }
    
    func testThatAListenerCanIgnoreNotInterestingProducers() {
        let listener = MockEventsListener<NoEvents>()
        listener.listenEvents(from: producer)
        XCTAssertEqual(listener.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanForwardProducers() {
        let first = MockEventsListener<MockEvent>()
        let second = MockEventsListener<NoEvents>()
        
        let aggregator = MockListenersAggregator(withListeners: [first, second])
        aggregator.listenEvents(from: producer)
        
        XCTAssertEqual(first.registeredProducers.count, 1)
        XCTAssertEqual(second.registeredProducers.count, 0)
    }
}
