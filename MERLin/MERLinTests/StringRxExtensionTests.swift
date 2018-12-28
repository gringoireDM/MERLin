//
//  StringRxExtensionTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 28/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa

@testable import MERLin

class StringRxExtensionTests: XCTestCase, RxExtensionTestCase {
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
    
    
    func testItCanCheckNonEmpty() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, "")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.isNotEmpty()
        }
        
        let expected = [
            Recorded.next(1, true),
            .next(2, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanChekEmpty() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, "")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.isEmpty()
        }
        
        let expected = [
            Recorded.next(1, false),
            .next(2, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCheckNonEmptyOptionals() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, ""),
            .next(3, nil)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.isNotEmpty()
        }
        
        let expected = [
            Recorded.next(1, true),
            .next(2, false),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }

    func testItCanChekEmptyOptionals() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, ""),
            .next(3, nil)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.isEmpty()
        }
        
        let expected = [
            Recorded.next(1, false),
            .next(2, true),
            .next(3, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    // MARK: Driver Extension
    func testItCanCheckNonEmptyDriver() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, "")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().isNotEmpty()
        }
        
        let expected = [
            Recorded.next(1, true),
            .next(2, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanChekEmptyDriver() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, "")
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().isEmpty()
        }
        
        let expected = [
            Recorded.next(1, false),
            .next(2, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanCheckNonEmptyDriverOptionals() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, ""),
            .next(3, nil)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().isNotEmpty()
        }
        
        let expected = [
            Recorded.next(1, true),
            .next(2, false),
            .next(3, false)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testItCanChekEmptyDriverOptionals() {
        let events = [
            Recorded.next(1, "Frank Sinatra"),
            .next(2, ""),
            .next(3, nil)
        ]
        
        let observer = buildTest(emitting: events) { emitter in
            return emitter.asDriverIgnoreError().isEmpty()
        }
        
        let expected = [
            Recorded.next(1, false),
            .next(2, true),
            .next(3, true)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}
