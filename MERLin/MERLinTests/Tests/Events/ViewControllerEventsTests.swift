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

class MockPageViewController: UIViewController, PageRepresenting {
    var pageName: String = "MockPage"
    var section: String = "Test"
    var type: String = "Mock"
}

class ViewControllerEventsTests: XCTestCase {
    var disposeBag: DisposeBag!
    var module: MockModule!
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        let context = ModuleContext(routingContext: "mock", building: MockModule.self)
        module = MockModule(usingContext: context)
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
            .completed(1) // ViewControlelr dies so it causes the completed.
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
    
    func testThatItCanHaveNewViewController() {
        let observer = makeObserverAndSubscribe()
        let expectedController = MockPageViewController()
        var controller: UIViewController!
        scheduler.scheduleAt(1) {
            controller = self.module.prepareRootViewController()
            controller.viewDidAppear(false)
        }
        scheduler.scheduleAt(2) {
            self.module.trackViewController(viewController: expectedController)
            controller.viewDidDisappear(false)
        }
        scheduler.start()
        
        let expected = [
            Recorded.next(0, ViewControllerEvent.uninitialized),
            .next(1, .initialized),
            .next(1, .appeared),
            .next(2, .newViewController(expectedController, events: .empty())),
            .next(2, .disappeared)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatCanHaveNewViewControllerEvents() {
        struct EventContainer: Equatable {
            var event: ViewControllerEvent
            var pageName: String
            var section: String
            var type: String
            init(_ event: ViewControllerEvent, _ pageName: String, _ section: String, _ type: String) {
                self.event = event
                self.pageName = pageName
                self.section = section
                self.type = type
            }
        }
        
        let observer = scheduler.createObserver(EventContainer.self)
        
        Observable.merge(
            module.viewControllerEvent
                .exclude(event: ViewControllerEvent.newViewController)
                .map { [unowned self] in EventContainer($0, self.module.moduleName, self.module.moduleSection, self.module.moduleType) },
            module.viewControllerEvent.capture(event: ViewControllerEvent.newViewController)
                .flatMap { (vc, obs) in obs.map { EventContainer($0, vc.pageName, vc.section, vc.type) } }
        ).subscribe(observer)
            .disposed(by: disposeBag)
        
        let expectedController = MockPageViewController()
        var controller: UIViewController!
        scheduler.scheduleAt(1) {
            controller = self.module.prepareRootViewController()
            controller.viewDidAppear(false)
        }
        scheduler.scheduleAt(2) {
            self.module.trackViewController(viewController: expectedController)
            controller.viewDidDisappear(false)
            expectedController.viewDidAppear(false)
        }
        scheduler.scheduleAt(3) {
            expectedController.viewDidDisappear(false)
        }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(0, EventContainer(.uninitialized, module!.moduleName, module!.moduleSection, module!.moduleType)),
            .next(1, EventContainer(.initialized, module!.moduleName, module!.moduleSection, module!.moduleType)),
            .next(1, EventContainer(.appeared, module!.moduleName, module!.moduleSection, module!.moduleType)),
            .next(2, EventContainer(.initialized, expectedController.pageName, expectedController.section, expectedController.type)),
            .next(2, EventContainer(.disappeared, module!.moduleName, module!.moduleSection, module!.moduleType)),
            .next(2, EventContainer(.appeared, expectedController.pageName, expectedController.section, expectedController.type)),
            .next(3, EventContainer(.disappeared, expectedController.pageName, expectedController.section, expectedController.type))
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}
