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
        let events = producer.observable(of: MockEvent.self)
        XCTAssertNotNil(events)
    }
    
    func testThatItCanBuildAnAnyEventProxy() {
        let events = producer.observable(of: AnyEvent.self)
        XCTAssertNotNil(events)
    }
    
    func testThatItCanFailCreatingAProxy() {
        let events = producer.observable(of: NoEvents.self)
        XCTAssertNil(events)
    }
    
    func testThatItCanEmitEventsThroughProxy() {
        let observer = scheduler.createObserver(MockEvent.self)
        let events = producer.observable(of: MockEvent.self)
        events?
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(.noPayload) }
        
        scheduler.start()

        let expected: [Recorded<Event<MockEvent>>] = [
            .next(1, .noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanEmitEventsThroughAnyEventProxy() {
        let observer = scheduler.createObserver(MockEvent.self)
        let events = producer.observable(of: AnyEvent.self)
        events?.capture(event: MockEvent.noPayload)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(.noPayload) }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(1, MockEvent.noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanEmitEventsThroughProducerSubscript() {
        let observer = scheduler.createObserver(MockEvent.self)

        producer[event: MockEvent.noPayload]
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(.noPayload) }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(1, MockEvent.noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanCapturePayloadsThroughProxy() {
        let expectedPayload = "David Bowie"
        let observer = scheduler.createObserver(String.self)
        let events = producer.observable(of: MockEvent.self)
        events?.capture(event: MockEvent.withAnonymousPayload)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.withAnonymousPayload(expectedPayload)) }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(1, expectedPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanCapturePayloadsThroughAnyEventProxy() {
        let expectedPayload = "David Bowie"
        let observer = scheduler.createObserver(String.self)
        let events = producer.observable(of: AnyEvent.self)
        events?.capture(event: MockEvent.withAnonymousPayload)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.withAnonymousPayload(expectedPayload)) }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(1, expectedPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanCapturePayloadsThroughSubscript() {
        let expectedPayload = "David Bowie"
        let observer = scheduler.createObserver(String.self)
        
        producer[event: MockEvent.withAnonymousPayload]
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.withAnonymousPayload(expectedPayload)) }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(1, expectedPayload)
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
