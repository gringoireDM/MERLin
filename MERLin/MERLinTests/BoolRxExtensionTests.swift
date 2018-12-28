//
//  BoolRxExtensionTests.swift
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

class BoolRxExtensionTests: XCTestCase, RxExtensionTestCase {
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
    
    func testItCanNegate() {
        let events = [
            Recorded.next(1, true),
            .next(2, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.negate()
        }
        
        let expected = [
            Recorded.next(1, false),
            .next(2, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanNegateOptionals() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.negate(ifNil: false)
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, false),
            .next(2, false),
            .next(3, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanTakeTrue() {
        let events = [
            Recorded.next(1, true),
            .next(2, false),
            .next(3, true)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.takeTrue()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .next(3, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanTakeFalse() {
        let events = [
            Recorded.next(1, true),
            .next(2, false),
            .next(3, true)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.takeFalse()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(2, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanNegateDriver() {
        let events = [
            Recorded.next(1, true),
            .next(2, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().negate()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, false),
            .next(2, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanNegateOptionalsDriver() {
        let events = [
            Recorded.next(1, true),
            .next(2, nil),
            .next(3, false)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().negate(ifNil: false)
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, false),
            .next(2, false),
            .next(3, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanTakeTrueDriver() {
        let events = [
            Recorded.next(1, true),
            .next(2, false),
            .next(3, true)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().takeTrue()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(1, true),
            .next(3, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanTakeFalseDriver() {
        let events = [
            Recorded.next(1, true),
            .next(2, false),
            .next(3, true)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().takeFalse()
        }
        
        let expected: [Recorded<Event<Bool>>] = [
            .next(2, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}
