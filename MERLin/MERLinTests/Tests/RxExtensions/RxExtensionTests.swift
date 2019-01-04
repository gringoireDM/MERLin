//
//  RxExtensionTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 26/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

@testable import MERLin

class RxExtensionTests: XCTestCase, RxExtensionTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        disposeBag = nil
        scheduler = nil
        super.tearDown()
    }
    
    // MARK: Observable Extension
    
    func testItCanUnwrap() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.unwrap()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCompactMap() {
        let events = [
            Recorded.next(1, "1"),
            .next(2, "2"),
            .next(3, "a")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter
                .compactMap(Int.init)
        }
        
        let expected: [Recorded<Event<Int>>] = [
            .next(1, 1),
            .next(2, 2)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanMapToVoid() {
        let events = [
            Recorded.next(1, "1"),
            .next(2, "2"),
            .next(3, "a")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.toVoid()
        }
        
        let expected = [
            Recorded.next(1, ()),
            .next(2, ()),
            .next(3, ())
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanMapToRoutableObservable() {
        let events = [
            Recorded.next(1, "a"),
            .next(2, "b"),
            .next(3, "c")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.toRoutableObservable(throttleTime: 5, scheduler: scheduler)
        }
        
        XCTAssertEqual(observer.events.map { $0.value.element }, ["a"])
    }
    
    // MARK: Driver Extension
    
    func testItCanUnwrapDriver() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().unwrap()
        }
        
        let expected = [
            Recorded.next(1, true),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCompactMapDriver() {
        let events = [
            Recorded.next(1, "1"),
            .next(2, "2"),
            .next(3, "a")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError()
                .compactMap(Int.init)
        }
        
        let expected = [
            Recorded.next(1, 1),
            .next(2, 2)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testDriverCanSendError() {
        let errors = PublishSubject<DisplayableError>()
        let events = [
            Recorded.next(1, "1"),
            .error(2, "error"),
            .next(3, "3")
        ]
        
        let errorObserver = scheduler.createObserver(String.self)
        errors
            .compactMap { $0.errorMessage }
            .subscribe(errorObserver)
            .disposed(by: disposeBag)
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriver(onErrorSendErrorTo: errors)
        }
        
        XCTAssertEqual(observer.events, [Recorded.next(1, "1"), .completed(2)])
        XCTAssertEqual(errorObserver.events, [Recorded.next(2, "error")])
    }
    
    // MARK: Single Extension
    
    func testItCanUnwrapSingle() {
        let value: Bool? = true
        
        let observer = buildTest(value: value) { emitter in
            return emitter.unwrapOrError("error")
        }
        
        let expected = [
            Recorded.next(200, true),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanUnwrapErrorSingle() {
        let value: Bool? = nil
        
        let observer = buildTest(value: value) { emitter in
            return emitter.unwrapOrError("error")
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .error(200, "error")
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanSwitchSingle() {
        let value: Bool? = nil
        let fallback = Single.just(true)
        
        let observer = buildTest(value: value) { emitter in
            return emitter.unwrapOrSwitch(to: fallback)
        }
        
        let expected = [
            Recorded.next(200, true),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanMapToVoidSingle() {
        let observer = buildTest(value: true) { emitter in
            return emitter.toVoid()
        }
        
        let expected = [
            Recorded.next(200, ()),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    // MARK: Maybe Extension
    
    func testItCanCompactMapMaybe() {
        let observer = buildTest(value: "1") { emitter in
            return emitter.asMaybe()
                .compactMap(Int.init)
        }
        
        let expected = [
            Recorded.next(200, 1),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}

extension String: DisplayableError {
    public var title: String? { return nil }
    public var errorMessage: String? { return self }
}
