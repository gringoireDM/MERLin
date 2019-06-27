//
//  ModuleListenerTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 21/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import XCTest

class ModuleListenerTests: XCTestCase {
    func module<T: EventProtocol>(emitting eventsType: T.Type, routingContext: String = "default") -> MockModule<T> {
        let context = ModuleContext(routingContext: routingContext, building: MockModule<T>.self)
        return MockModule(usingContext: context)
    }
    
    func testThatAnyModuleListenerCanRegisterToAModuleEventsProducer() {
        let producer = module(emitting: AnyEvent.self)
        
        let listener = MockAnyModuleListener()
        XCTAssertTrue(listener.listenEvents(from: producer))
        XCTAssertEqual(listener.registeredProducers.count, 1)
        XCTAssert(listener.registeredProducers.first === producer)
    }
    
    func testThatAnyModuleListenerCanIgnoreNonModuleProducers() {
        let producer = MockProducer<MockEvent>()
        
        let listener = MockAnyModuleListener()
        XCTAssertFalse(listener.listenEvents(from: producer))
        XCTAssertEqual(listener.registeredProducers.count, 0)
    }
    
    func testThatAnyModuleListenerCanRegisterToAModuleEventsProducerWhenPassedAsNonModule() {
        let producer = module(emitting: AnyEvent.self) as AnyEventsProducer
        
        let listener = MockAnyModuleListener()
        XCTAssertTrue(listener.listenEvents(from: producer))
        XCTAssertEqual(listener.registeredProducers.count, 1)
        XCTAssert(listener.registeredProducers.first === producer)
    }
    
    func testThatAListenerCanRegisterToASpecificEventsProducer() {
        let producer = module(emitting: MockEvent.self)
        
        let listener = MockModuleListener<MockEvent>()
        XCTAssertTrue(listener.listenEvents(from: producer))
        XCTAssertEqual(listener.registeredProducers.count, 1)
        XCTAssert(listener.registeredProducers.first === producer)
    }
    
    func testThatAListenerCanRegisterToASpecificEventsProducerWhenPassedAsNonModule() {
        let producer = module(emitting: MockEvent.self) as AnyEventsProducer
        
        let listener = MockModuleListener<MockEvent>()
        XCTAssertTrue(listener.listenEvents(from: producer))
        XCTAssertEqual(listener.registeredProducers.count, 1)
        XCTAssert(listener.registeredProducers.first === producer)
    }
    
    func testThatAListenerCanIgnoreNotInterestingProducers() {
        let producer = module(emitting: MockEvent.self)
        
        let listener = MockModuleListener<NoEvents>()
        XCTAssertFalse(listener.listenEvents(from: producer))
        XCTAssertEqual(listener.registeredProducers.count, 0)
    }
    
    func testThatAModuleListenerCanIgnoreNonModuleProducers() {
        let producer = MockProducer<MockEvent>()
        let listener = MockModuleListener<MockEvent>()
        XCTAssertFalse(listener.listenEvents(from: producer))
        XCTAssertEqual(listener.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanForwardProducers() {
        let producer = module(emitting: MockEvent.self)
        
        let first = MockModuleListener<MockEvent>()
        let second = MockModuleListener<NoEvents>()
        
        let aggregator = MockModuleListenersAggregator(withListeners: [first, second])
        
        XCTAssertTrue(aggregator.listenEvents(from: producer))
        XCTAssertEqual(first.registeredProducers.count, 1)
        XCTAssertEqual(second.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanFilterNonModuleProducers() {
        let producer = MockProducer<MockEvent>()
        let first = MockModuleListener<MockEvent>()
        let second = MockModuleListener<NoEvents>()
        
        let aggregator = MockModuleListenersAggregator(withListeners: [first, second])
        
        XCTAssertFalse(aggregator.listenEvents(from: producer))
        XCTAssertEqual(first.registeredProducers.count, 0)
        XCTAssertEqual(second.registeredProducers.count, 0)
    }
    
    func testThatAnAggregatorCanFilterRoutingContexts() {
        let validProducer = module(emitting: MockEvent.self, routingContext: "valid1")
        let otherValidProducer = module(emitting: NoEvents.self, routingContext: "valid2")
        let invalidProducer = module(emitting: MockEvent.self, routingContext: "invalid")
        
        let first = MockModuleListener<MockEvent>()
        let second = MockModuleListener<NoEvents>()
        
        let aggregator = MockModuleListenersAggregator(withListeners: [first, second], handledContexts: ["valid1", "valid2"])
        
        XCTAssertTrue(aggregator.listenEvents(from: validProducer))
        XCTAssertTrue(aggregator.listenEvents(from: otherValidProducer))
        XCTAssertFalse(aggregator.listenEvents(from: invalidProducer))
        
        XCTAssertEqual(first.registeredProducers.count, 1)
        XCTAssertEqual(second.registeredProducers.count, 1)
    }
}
