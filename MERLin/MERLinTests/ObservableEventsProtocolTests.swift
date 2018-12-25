//
//  ObservableEventsProtocolTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 23/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa

@testable import MERLin

class ObservableEventsProtocolTests: XCTestCase {
    var scheduler: TestScheduler!
    var emitter: PublishSubject<EventProtocol>!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()

        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        emitter = PublishSubject<EventProtocol>()
    }

    override func tearDown() {
        disposeBag = nil
        scheduler = nil
        emitter = nil
        super.tearDown()
    }
    
    func testThatItCanListenToSpecificEvents() {
        let observer = scheduler.createObserver(MockEvent.self)
        emitter
            .listen(to: MockEvent.self)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.noPayload) }
        scheduler.start()
        
        let expected: [Recorded<Event<MockEvent>>] = [
            next(1, MockEvent.noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanIgnoreEvents() {
        let observer = scheduler.createObserver(NoEvents.self)
        emitter
            .listen(to: NoEvents.self)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.noPayload) }
        scheduler.start()
        
        let expected: [Recorded<Event<NoEvents>>] = []
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCaptureSpecificEvent() {
        let observer = scheduler.createObserver(MockEvent.self)
        emitter
            .capture(event: MockEvent.noPayload)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.noPayload) }
        scheduler.scheduleAt(2) { self.emitter.onNext(MockEvent.anotherWithoutPayload) }
        scheduler.start()
        
        let expected: [Recorded<Event<MockEvent>>] = [
            next(1, MockEvent.noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCaptureSpecificEventWithPayload() {
        let expectedEvent = MockEvent.withAnonymousPayload("Life on Mars")
        let observer = scheduler.createObserver(String.self)
        emitter
            .capture(event: MockEvent.withAnonymousPayload)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.noPayload) }
        scheduler.scheduleAt(2) { self.emitter.onNext(MockEvent.anotherWithoutPayload) }
        scheduler.scheduleAt(3) { self.emitter.onNext(expectedEvent) }
        scheduler.start()
        
        let expected: [Recorded<Event<String>>] = [
            next(3, expectedEvent.extractPayload()!)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatDriverCanCaptureEvents() {
        let observer = scheduler.createObserver(MockEvent.self)
        emitter
            .listen(to: MockEvent.self)
            .asDriverIgnoreError()
            .capture(event: MockEvent.noPayload)
            .drive(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.noPayload) }
        scheduler.scheduleAt(2) { self.emitter.onNext(MockEvent.anotherWithoutPayload) }
        scheduler.start()
        
        let expected: [Recorded<Event<MockEvent>>] = [
            next(1, MockEvent.noPayload)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatDriverCanCaptureSpecificEventWithPayload() {
        let expectedEvent = MockEvent.withAnonymousPayload("Life on Mars")
        let observer = scheduler.createObserver(String.self)
        emitter
            .listen(to: MockEvent.self)
            .asDriverIgnoreError()
            .capture(event: MockEvent.withAnonymousPayload)
            .drive(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) { self.emitter.onNext(MockEvent.noPayload) }
        scheduler.scheduleAt(2) { self.emitter.onNext(MockEvent.anotherWithoutPayload) }
        scheduler.scheduleAt(3) { self.emitter.onNext(expectedEvent) }
        scheduler.start()
        
        let expected: [Recorded<Event<String>>] = [
            next(3, expectedEvent.extractPayload()!)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }

}
