//
//  ModuleTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 03/01/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import RxSwift
import RxTest
import XCTest

class ModuleTests: XCTestCase {
    var module: MockModule!
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        module = MockModule(usingContext: ModuleContext(building: MockModule.self))
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        module = nil
        super.tearDown()
    }
    
    func testItCanStoreRootViewController() {
        let viewController = UIViewController()
        module.rootViewController = viewController
        
        XCTAssert(viewController === module.rootViewController)
    }
    
    func testItCanThrowRootviewController() {
        let viewController = UIViewController()
        module.rootViewController = viewController
        module.rootViewController = nil
        XCTAssertNil(module.rootViewController)
    }
    
    func testThatItHasWeakReferenceToViewController() {
        var viewController: UIViewController? = UIViewController()
        module.rootViewController = viewController
        autoreleasepool { viewController = nil }
        XCTAssertNil(module.rootViewController)
    }
    
    func testThatCanPrepareRootViewController() {
        let controller = module.prepareRootViewController()
        XCTAssert(controller === module.rootViewController)
    }
    
    func testThatCanReusePreviouslyPreparedRootViewController() {
        let controller = module.prepareRootViewController()
        let cachedController = module.prepareRootViewController()
        XCTAssert(controller === cachedController)
    }
    
    func testThatDisposeBagIsUnique() {
        let disposeBag = module.disposeBag
        let cachedDisposeBag = module.disposeBag
        XCTAssert(disposeBag === cachedDisposeBag)
    }
    
    func testThatNewViewControllerObservableIsUnique() {
        let observable = module.newViewControllers
        XCTAssert(observable === module.newViewControllers)
    }
    
    func testThatNewViewControllerEmitsRootViewControllerAsInitialValue() {
        let expectedVC = module.prepareRootViewController()
        
        let observer = scheduler.createObserver(UIViewController.self)
        
        module.newViewControllers
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let expected = [
            Recorded.next(0, expectedVC)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatNewViewControllerEmitsRootViewController() {
        let observer = scheduler.createObserver(UIViewController.self)
        var expectedVC: UIViewController!
        module.newViewControllers
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) {
            expectedVC = self.module.prepareRootViewController()
        }
        scheduler.start()
        
        let expected = [
            Recorded.next(1, expectedVC!)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    func testThatNewViewControllerDoesNotRetainViewControllers() {
        autoreleasepool { _ = module.prepareRootViewController() }
        // It's proved by previous tests that at this point the observable
        // exists and an event is already sent with the rootViewController
        
        let observer = scheduler.createObserver(UIViewController.self)
        
        module.newViewControllers
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [])
    }
    
    func testThatModuleCanEmitNewViewControllers() {
        let root = module.prepareRootViewController()
        let newVC = MockViewController()
        
        let observer = scheduler.createObserver(UIViewController.self)
        
        module.newViewControllers
            .subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) {
            self.module.signalNew(viewController: newVC)
        }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(0, root),
            .next(1, newVC)
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
    
    struct VCEvent: Equatable {
        var controller: UIViewController
        var event: ViewControllerEvent
        init(_ controller: UIViewController, _ event: ViewControllerEvent) {
            self.controller = controller
            self.event = event
        }
    }
    
    func testViewControllerFlowScenario() {
        let root = module.prepareRootViewController()
        let newVC = MockViewController()
        
        let observer = scheduler.createObserver(VCEvent.self)
        
        module.newViewControllers
            .flatMap { controller in
                controller.events
                    .map { (controller, $0) }
                    .map(VCEvent.init) // In real world applications i suggest to capture an identifier
            }.subscribe(observer)
            .disposed(by: disposeBag)
        
        scheduler.scheduleAt(1) {
            root.viewWillAppear(false)
            root.viewDidAppear(false)
        }
        
        scheduler.scheduleAt(2) {
            self.module.signalNew(viewController: newVC)
        }
        
        scheduler.scheduleAt(3) {
            root.viewWillDisappear(false)
            newVC.viewWillAppear(false)
            root.viewDidDisappear(false)
            newVC.viewDidAppear(false)
        }
        
        scheduler.start()
        
        let expected = [
            Recorded.next(1, VCEvent(root, .willAppear)),
            .next(1, VCEvent(root, .appeared)),
            .next(3, VCEvent(root, .willDisappear)),
            .next(3, VCEvent(newVC, .willAppear)),
            .next(3, VCEvent(root, .disappeared)),
            .next(3, VCEvent(newVC, .appeared))
        ]
        
        XCTAssertEqual(observer.events, expected)
    }
}
