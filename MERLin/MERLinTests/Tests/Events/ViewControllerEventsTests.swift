//
//  ViewControllerEventsTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
@testable import MERLin

class ViewControllerEventsTests: XCTestCase {
    var disposeBag: DisposeBag!
    var module: MockModule!
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        module = MockModule(usingContext: ModuleContext(routingContext: "mock"))
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        disposeBag = nil
        module = nil
        scheduler = nil
        super.tearDown()
    }
    
    func makeObserverAndSubscribe() -> TestableObserver<ViewControllerEvent> {
        let observer = scheduler.createObserver(ViewControllerEvent.self)
        
        module.viewControllerEvent
            .subscribe(observer)
            .disposed(by: disposeBag)

        return observer
    }
    
    func testThatItCanStoreTheObservable() {
        let observable = module.viewControllerEvent
        XCTAssertTrue(observable === module.viewControllerEvent)
    }
    
    func testThatInitialStateIsUninitialised() {
        let observer = makeObserverAndSubscribe()
        scheduler.start()

        let expected = [
            Recorded.next(0, ViewControllerEvent.uninitialized)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatStateChangeToInitialised() {
        let observer = makeObserverAndSubscribe()
        scheduler.scheduleAt(1) {
            _ = self.module.prepareRootViewController()
        }
        
        scheduler.start()

        let expected = [
            Recorded.next(0, ViewControllerEvent.uninitialized),
            .next(1, .initialized),
            .completed(1) //ViewControlelr dies so it causes the completed.
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatStateChangeToAppeared() {
        let observer = makeObserverAndSubscribe()
        var controller: UIViewController!
        scheduler.scheduleAt(1) {
            controller = self.module.prepareRootViewController()
        }
        scheduler.scheduleAt(2) {
            controller.viewDidAppear(false)
        }
        scheduler.start()
        
        let expected = [
            Recorded.next(0, ViewControllerEvent.uninitialized),
            .next(1, .initialized),
            .next(2, .appeared)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanChangeToDisappeared() {
        let observer = makeObserverAndSubscribe()
        var controller: UIViewController!
        scheduler.scheduleAt(1) {
            controller = self.module.prepareRootViewController()
            controller.viewDidAppear(false)
        }
        scheduler.scheduleAt(2) {
            controller.viewDidDisappear(false)
        }
        scheduler.start()
        
        let expected = [
            Recorded.next(0, ViewControllerEvent.uninitialized),
            .next(1, .initialized),
            .next(1, .appeared),
            .next(2, .disappeared)
            ]
        
        XCTAssertEqual(observer.events, expected)
    }
}
