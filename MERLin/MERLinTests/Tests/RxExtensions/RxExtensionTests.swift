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
            emitter.unwrap()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .next(3, false)
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
            emitter.toVoid()
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
            emitter.toRoutableObservable(throttleTime: .seconds(5), scheduler: scheduler)
        }
        
        XCTAssertEqual(observer.events.map { $0.value.element }, ["a"])
    }
    
    func testItCanCompactFlatMapFirst() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            emitter.compactFlatMapFirst { value -> Observable<Bool>? in
                guard let value = value else { return nil }
                return Observable<Bool>.just(value)
            }
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCompactFlatMap() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            emitter.compactFlatMap { value -> Observable<Bool>? in
                guard let value = value else { return nil }
                return Observable<Bool>.just(value)
            }
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCompactFlatMapLatest() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            emitter.compactFlatMapLatest { value -> Observable<Bool>? in
                guard let value = value else { return nil }
                return Observable<Bool>.just(value)
            }
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    // MARK: Driver Extension
    
    func testItCanUnwrapDriver() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            emitter.asDriverIgnoreError().unwrap()
        }
        
        let expected = [
            Recorded.next(1, true),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    // MARK: Single Extension
    
    func testItCanUnwrapSingle() {
        let value: Bool? = true
        
        let observer = buildTest(value: value) { emitter in
            emitter.unwrapOrError("error")
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
            emitter.unwrapOrError("error")
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
            emitter.unwrapOrSwitch(to: fallback)
        }
        
        let expected = [
            Recorded.next(200, true),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanMapToVoidSingle() {
        let observer = buildTest(value: true) { emitter in
            emitter.toVoid()
        }
        
        let expected = [
            Recorded.next(200, ()),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCompactFlatMapSingle() {
        let value: Bool? = true
        let observer = buildTest(value: value) { emitter in
            emitter.compactFlatMapOrSwitch(to: .just(false)) {
                guard let value = $0 else { return nil }
                return .just(value)
            }
        }
        
        let expected = [
            Recorded.next(200, true),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanSwitchOnCompactFlatMapSingle() {
        let value: Bool? = nil
        let observer = buildTest(value: value) { emitter in
            emitter.compactFlatMapOrSwitch(to: .just(false)) {
                guard let value = $0 else { return nil }
                return .just(value)
            }
        }
        
        let expected = [
            Recorded.next(200, false),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCompactFlatMapWithoutErroringSingle() {
        let value: Bool? = true
        let observer = buildTest(value: value) { emitter in
            emitter.compactFlatMapOrError("Error") { val -> Single<Bool>? in
                guard let value = val else { return nil }
                return .just(value)
            }
        }
        
        let expected = [
            Recorded.next(200, true),
            .completed(200)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanErrorOnCompactFlatMapSingle() {
        let value: Bool? = nil
        let expectedError: Error = "error"
        let observer = buildTest(value: value) { emitter in
            emitter.compactFlatMapOrError(expectedError) { val -> Single<Bool>? in
                guard let value = val else { return nil }
                return .just(value)
            }
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .error(200, expectedError)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}

extension String: Error {}
