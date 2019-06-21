//
//  ModuleConsumerTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 21/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import XCTest

class ModuleConsumerTests: XCTestCase {
    func module<T: EventProtocol>(emitting eventsType: T.Type, routingContext: String = "default") -> MockModule<T> {
        let context = ModuleContext(routingContext: routingContext, building: MockModule<T>.self)
        return MockModule(usingContext: context)
    }
    
    func testThatAnyModuleConsumerCanRegisterToAModuleEventsProducer() {
        let producer = module(emitting: AnyEvent.self)
        
        let consumer = MockAnyModuleConsumer()
        XCTAssertTrue(consumer.consumeEvents(from: producer))
        XCTAssertEqual(consumer.registeredProducers.count, 1)
        XCTAssert(consumer.registeredProducers.first === producer)
    }
    
    func testThatAnyModuleConsumerCanIgnoreNonModuleProducers() {
        let producer = MockProducer<MockEvent>()
        
        let consumer = MockAnyModuleConsumer()
        XCTAssertFalse(consumer.consumeEvents(from: producer))
        XCTAssertEqual(consumer.registeredProducers.count, 0)
    }
    
    func testThatAnyModuleConsumerCanRegisterToAModuleEventsProducerWhenPassedAsNonModule() {
        let producer = module(emitting: AnyEvent.self) as AnyEventsProducer
        
        let consumer = MockAnyModuleConsumer()
        XCTAssertTrue(consumer.consumeEvents(from: producer))
        XCTAssertEqual(consumer.registeredProducers.count, 1)
        XCTAssert(consumer.registeredProducers.first === producer)
    }
    
    func testThatAConsumerCanRegisterToASpecificEventsProducer() {
        let producer = module(emitting: MockEvent.self)
        
        let consumer = MockModuleConsumer<MockEvent>()
        XCTAssertTrue(consumer.consumeEvents(from: producer))
        XCTAssertEqual(consumer.registeredProducers.count, 1)
        XCTAssert(consumer.registeredProducers.first === producer)
    }
    
    func testThatAConsumerCanRegisterToASpecificEventsProducerWhenPassedAsNonModule() {
        let producer = module(emitting: MockEvent.self) as AnyEventsProducer
        
        let consumer = MockModuleConsumer<MockEvent>()
        XCTAssertTrue(consumer.consumeEvents(from: producer))
        XCTAssertEqual(consumer.registeredProducers.count, 1)
        XCTAssert(consumer.registeredProducers.first === producer)
    }
    
    func testThatAConsumerCanIgnoreNotInterestingProducers() {
        let producer = module(emitting: MockEvent.self)
        
        let consumer = MockModuleConsumer<NoEvents>()
        XCTAssertFalse(consumer.consumeEvents(from: producer))
        XCTAssertEqual(consumer.registeredProducers.count, 0)
    }
    
    func testThatAModuleConsumerCanIgnoreNonModuleProducers() {
        let producer = MockProducer<MockEvent>()
        let consumer = MockModuleConsumer<MockEvent>()
        XCTAssertFalse(consumer.consumeEvents(from: producer))
        XCTAssertEqual(consumer.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanForwardProducers() {
        let producer = module(emitting: MockEvent.self)
        
        let first = MockModuleConsumer<MockEvent>()
        let second = MockModuleConsumer<NoEvents>()
        
        let aggregator = MockModuleConsumerAggregator(withConsumers: [first, second])
        
        XCTAssertTrue(aggregator.consumeEvents(from: producer))
        XCTAssertEqual(first.registeredProducers.count, 1)
        XCTAssertEqual(second.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanFilterNonModuleProducers() {
        let producer = MockProducer<MockEvent>()
        let first = MockModuleConsumer<MockEvent>()
        let second = MockModuleConsumer<NoEvents>()
        
        let aggregator = MockModuleConsumerAggregator(withConsumers: [first, second])
        
        XCTAssertFalse(aggregator.consumeEvents(from: producer))
        XCTAssertEqual(first.registeredProducers.count, 0)
        XCTAssertEqual(second.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanFilterRoutingContexts() {
        let validProducer = module(emitting: MockEvent.self, routingContext: "valid1")
        let otherValidProducer = module(emitting: NoEvents.self, routingContext: "valid2")
        let invalidProducer = module(emitting: MockEvent.self, routingContext: "invalid")
        
        let first = MockModuleConsumer<MockEvent>()
        let second = MockModuleConsumer<NoEvents>()
        
        let aggregator = MockModuleConsumerAggregator(withConsumers: [first, second], handledContexts: ["valid1", "valid2"])
        
        XCTAssertTrue(aggregator.consumeEvents(from: validProducer))
        XCTAssertTrue(aggregator.consumeEvents(from: otherValidProducer))
        XCTAssertFalse(aggregator.consumeEvents(from: invalidProducer))
        
        XCTAssertEqual(first.registeredProducers.count, 1)
        XCTAssertEqual(second.registeredProducers.count, 1)
    }
}
