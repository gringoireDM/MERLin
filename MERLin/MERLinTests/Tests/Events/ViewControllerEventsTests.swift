//
//  ViewControllerEventsTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import RxSwift
import RxTest
import XCTest

class ViewControllerEventsTests: XCTestCase {
    var disposeBag: DisposeBag!
    var viewController: MockViewController!
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        viewController = MockViewController()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        disposeBag = nil
        viewController = nil
        scheduler = nil
        super.tearDown()
    }
    
    func makeObserverAndSubscribe() -> TestableObserver<ViewControllerEvent> {
        let observer = scheduler.createObserver(ViewControllerEvent.self)
        
        viewController.events
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        return observer
    }
    
    func testThatItCanStoreTheObservable() {
        let observable = viewController.events
        XCTAssertTrue(observable === viewController.events)
    }
    
    func testThatStateChangeToAppeared() {
        let observer = makeObserverAndSubscribe()
        
        scheduler.scheduleAt(1) {
            self.viewController.viewWillAppear(false)
            self.viewController.viewDidAppear(false)
        }
        scheduler.start()
        
        let expected = [
            Recorded.next(1, ViewControllerEvent.willAppear),
            .next(1, .appeared)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatItCanChangeToDisappeared() {
        let observer = makeObserverAndSubscribe()
        scheduler.scheduleAt(1) {
            self.viewController.viewDidAppear(false)
        }
        scheduler.scheduleAt(2) {
            self.viewController.viewWillDisappear(false)
            self.viewController.viewDidDisappear(false)
        }
        scheduler.start()
        
        let expected = [
            Recorded.next(1, ViewControllerEvent.appeared),
            .next(2, .willDisappear),
            .next(2, .disappeared)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}
