//
//  ModuleManagerTests.swift
//  TheBayTests
//
//  Created by Giuseppe Lanza on 08/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
import RxSwift
@testable import MERLin

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
        
        let eventsListener = MockAnyEventsListener()
        
        moduleManager.addEventsListeners([eventsListener])

        XCTAssertEqual(eventsListener.registeredProducers.count, controllers.count)
    }
}
