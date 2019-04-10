//
//  RxExtensionTestCase.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 26/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxTest

import XCTest

protocol RxExtensionTestCase {
    var scheduler: TestScheduler! { get }
    var disposeBag: DisposeBag! { get }
}

extension RxExtensionTestCase {
    func buildTest<Value, Expected>(emitting events: [Recorded<Event<Value>>], test: (TestableObservable<Value>) -> Observable<Expected>) -> TestableObserver<Expected> {
        let emitter = scheduler.createHotObservable(events)
        let observer = scheduler.createObserver(Expected.self)
        
        test(emitter)
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        return observer
    }
    
    func buildTest<Value, Expected>(emitting events: [Recorded<Event<Value>>], test: (TestableObservable<Value>) -> Driver<Expected>) -> TestableObserver<Expected> {
        let emitter = scheduler.createHotObservable(events)
        let observer = scheduler.createObserver(Expected.self)
        
        test(emitter)
            .drive(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        return observer
    }
    
    func buildTest<Value, Expected, Trait>(value: Value, test: @escaping (Single<Value>) -> PrimitiveSequence<Trait, Expected>) -> TestableObserver<Expected> {
        let observer = scheduler.start { () -> Observable<Expected> in
            let emitter = Single.just(value)
            return test(emitter).asObservable()
        }
        
        return observer
    }
}

func == (lhs: Event<Void>, rhs: Event<Void>) -> Bool {
    switch (lhs, rhs) {
    case (.next, .next),
         (.completed, .completed):
        return true
        
    case let (.error(lhsErr), .error(rhsErr)):
        let error1 = lhsErr as NSError
        let error2 = rhsErr as NSError
        
        return error1.domain == error2.domain
            && error1.code == error2.code
            && "\(lhsErr)" == "\(rhsErr)"
        
    default: return false
    }
}

func == (lhs: Recorded<Event<Void>>, rhs: Recorded<Event<Void>>) -> Bool {
    return lhs.time == rhs.time && lhs.value == rhs.value
}

func XCTAssertEqual(_ lhs: [Recorded<Event<Void>>], _ rhs: [Recorded<Event<Void>>], file: StaticString = #file, line: UInt = #line) {
    guard lhs.count == rhs.count else {
        XCTFail(file: file, line: line)
        return
    }
    
    XCTAssert(zip(lhs, rhs).reduce(true) {
        $0 && $1.0 == $1.1
    }, file: file, line: line)
}
