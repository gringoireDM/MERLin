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

extension Recorded: Equatable where Value == Event<Void> {
    public static func == (lhs: Recorded<Value>, rhs: Recorded<Value>) -> Bool {
        return lhs.time == rhs.time
    }
}
