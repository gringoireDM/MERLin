//
//  RxExtensionTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 26/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa

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
        
        let expected: [Recorded<Event<Void>>] = [
            .next(1, ()),
            .next(2, ()),
            .next(3, ())
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanUnwrapDriver() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().unwrap()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
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
        
        let expected: [Recorded<Event<Int>>] = [
            .next(1, 1),
            .next(2, 2)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}
