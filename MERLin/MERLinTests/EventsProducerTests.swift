//
//  EventsProducerTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 24/11/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import MERLin

class EventsProducerTests: XCTestCase {
    var disposeBag: DisposeBag!
    var producer: AnyEventsProducer!
    var scheduler: TestScheduler!
    fileprivate var emitter: PublishSubject<MockEvent>!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        producer = MockProducer<MockEvent>()
        scheduler = TestScheduler(initialClock: 0)
        emitter = (producer as! MockProducer)._events
    }

    override func tearDown() {
        disposeBag = nil
        producer = nil
        scheduler = nil
        emitter = nil
        super.tearDown()
    }
    
    func testThatItCanBuildAProxy() {
        let proxy = producer.eventsProxy(MockEvent.self)
        XCTAssertNotNil(proxy)
    }
    
    func testThatItCanBuildAnAnyEventProxy() {
        let proxy = producer.eventsProxy(AnyEvent.self)
        XCTAssertNotNil(proxy)
    }
    
    func testThatItCanFailCreatingAProxy() {
        let proxy = producer.eventsProxy(NoEvents.self)
        XCTAssertNil(proxy)
    }
    
    func testThatItCanEmitEventsThroughProxy() {
        let observer = scheduler.createObserver(MockEvent.self)
        let proxy = producer.eventsProxy(MockEvent.self)
        proxy?.events
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(.noPayload) }
        
        scheduler.start()

        let expected: [Recorded<Event<MockEvent>>] = [
            next(1, .noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanEmitEventsThroughAnyEventProxy() {
        let observer = scheduler.createObserver(MockEvent.self)
        let proxy = producer.eventsProxy(AnyEvent.self)
        proxy?[event: MockEvent.noPayload]
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(.noPayload) }
        
        scheduler.start()
        
        let expected: [Recorded<Event<MockEvent>>] = [
            next(1, .noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanCapturePayloadsThroughProxy() {
        let expectedPayload = "David Bowie"
        let observer = scheduler.createObserver(String.self)
        let proxy = producer.eventsProxy(MockEvent.self)
        proxy?[event: MockEvent.withAnonymousPayload]
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.withAnonymousPayload(expectedPayload)) }
        
        scheduler.start()
        
        let expected: [Recorded<Event<String>>] = [
            next(1, expectedPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanCapturePayloadsThroughAnyEventProxy() {
        let expectedPayload = "David Bowie"
        let observer = scheduler.createObserver(String.self)
        let proxy = producer.eventsProxy(AnyEvent.self)
        proxy?[event: MockEvent.withAnonymousPayload]
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.withAnonymousPayload(expectedPayload)) }
        
        scheduler.start()
        
        let expected: [Recorded<Event<String>>] = [
            next(1, expectedPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatAListenerCanRegisterToASpecificEventsProducer() {
        let listener = MockEventsListener<MockEvent>()
        listener.registerToEvents(for: producer)
        XCTAssertEqual(listener.registeredProducers.count, 1)
        XCTAssert(listener.registeredProducers.first === producer)
    }
    
    func testThatAListenerCanIgnoreNotInterestingProducers() {
        let listener = MockEventsListener<NoEvents>()
        listener.registerToEvents(for: producer)
        XCTAssertEqual(listener.registeredProducers.count, 0)
    }
}
