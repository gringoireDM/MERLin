//
//  ModuleManagerTests.swift
//  TheBayTests
//
//  Created by Giuseppe Lanza on 08/02/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import XCTest
import RxSwift
@testable import MERLin

class MockEventsListener: EventsListening {
    var registeredModules = [EventsProducer]()
    
    func registerToEvents(for producer: EventsProducer) -> Bool {
        registeredModules.append(producer)
        return true
    }
}

class MockViewController: UIViewController { }

struct NoEvents: EventProtocol { }

class MockModule: NSObject, ModuleProtocol, EventsProducer {
    var context: ModuleContext
    
    var moduleName: String = "MockModule"
    var moduleSection: String = "ModuleTests"
    var moduleType: String = "test"
    var eventsType: EventProtocol.Type = NoEvents.self
    
    var events: Observable<EventProtocol> = PublishSubject<EventProtocol>()
    required init(usingContext buildContext: ModuleContext) {
        context = buildContext
        super.init()
    }
    
    func unmanagedRootViewController() -> UIViewController {
        return UIViewController()
    }
}

struct MockStep: ModuleMaking {
    var routingContext: String = ""
    
    var make: () -> (AnyModule, UIViewController) {
        return {
            return (MockModule(usingContext: ModuleContext()), MockViewController())
        }
    }
}

extension ModuleRoutingStep {
    static func mock() -> ModuleRoutingStep {
        return ModuleRoutingStep(withMaker: MockStep())
    }
}

class ModuleManagerTests: XCTestCase {
    var moduleManager: BaseModuleManager!
    override func setUp() {
        super.setUp()
        moduleManager = BaseModuleManager()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func mockStep() -> PresentableRoutingStep {
        return PresentableRoutingStep(withStep: .mock(), presentationMode: .push(withCloseButton: false, onClose: nil))
    }
    
    func testThatItCanRetainModules() {
        let viewController = moduleManager.viewController(for: mockStep())
        XCTAssertEqual(moduleManager.livingModules().count, 1)
        XCTAssertNotNil(moduleManager.module(for: viewController))
    }
    
    func testItCanAddEventsListeners() {
        let controllers = [moduleManager.viewController(for: mockStep()), moduleManager.viewController(for: mockStep())]
        
        let eventsListener = MockEventsListener()
        
        moduleManager.addEventsListeners([eventsListener])

        XCTAssertEqual(eventsListener.registeredModules.count, controllers.count)
    }
}
