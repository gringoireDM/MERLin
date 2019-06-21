//
//  EventsConsumerTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 21/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import XCTest

class EventsConsumerTests: XCTestCase {
    var producer: AnyEventsProducer!
    
    override func setUp() {
        super.setUp()
        producer = MockProducer<MockEvent>()
    }
    
    override func tearDown() {
        producer = nil
        super.tearDown()
    }
    
    func testThatAConsumerCanRegisterToASpecificEventsProducer() {
        let consumer = MockEventsConsumer<MockEvent>()
        consumer.consumeEvents(from: producer)
        XCTAssertEqual(consumer.registeredProducers.count, 1)
        XCTAssert(consumer.registeredProducers.first === producer)
    }
    
    func testThatAConsumerCanIgnoreNotInterestingProducers() {
        let consumer = MockEventsConsumer<NoEvents>()
        consumer.consumeEvents(from: producer)
        XCTAssertEqual(consumer.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanForwardProducers() {
        let first = MockEventsConsumer<MockEvent>()
        let second = MockEventsConsumer<NoEvents>()
        
        let aggregator = MockConsumersAggregator(withConsumers: [first, second])
        aggregator.consumeEvents(from: producer)
        
        XCTAssertEqual(first.registeredProducers.count, 1)
        XCTAssertEqual(second.registeredProducers.count, 0)
    }
}
