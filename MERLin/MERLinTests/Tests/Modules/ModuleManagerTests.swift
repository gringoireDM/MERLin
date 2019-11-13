//
//  ModuleManagerTests.swift
//  TheBayTests
//
//  Created by Giuseppe Lanza on 08/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import RxSwift
import RxTest
import XCTest

class ModuleManagerTests: XCTestCase {
    var moduleManager: BaseModuleManager!
    override func setUp() {
        super.setUp()
        moduleManager = BaseModuleManager()
    }
    
    override func tearDown() {
        moduleManager = nil
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
    
    func testThatItCanRetainModulesWithInternalRoutings() {
        var viewController: UIViewController? = moduleManager.viewController(for: mockStep())
        guard let module = moduleManager.module(for: viewController!) else {
            XCTFail("Expected to be there"); return
        }
        
        let newVC = MockViewController()
        module.signalNew(viewController: newVC)
        
        XCTAssertEqual(moduleManager.livingModules().count, 1)
        XCTAssertNotNil(moduleManager.module(for: viewController!))
        XCTAssertEqual(moduleManager.moduleRetainer.count, 2)
        
        autoreleasepool { viewController = nil }
        XCTAssertEqual(moduleManager.moduleRetainer.count, 1)
        XCTAssert(moduleManager.module(for: newVC)?.isEqual(module) == true)
    }
    
    func testItCanAddEventsListeners() {
        let controllers = [moduleManager.viewController(for: mockStep()), moduleManager.viewController(for: mockStep())]
        
        let eventsListener = MockAnyEventsListener()
        
        moduleManager.addEventsListeners([eventsListener])
        
        XCTAssertEqual(eventsListener.registeredProducers.count, controllers.count)
    }
    
    func testCorrectResponders() {
        let deeplink = "test://mock/product/1234"
        
        let type = moduleManager.deeplinkable(fromDeeplink: deeplink)
        XCTAssert(type == MockDeeplinkable.self)
        
        guard let remainder = MockDeeplinkable.remainderDeeplink(fromDeeplink: deeplink) else {
            XCTFail()
            return
        }
        
        let secondType = moduleManager.deeplinkable(fromDeeplink: remainder)
        XCTAssert(secondType == LowPriorityMockDeeplinkableModule.self)
    }
    
    func testThatItCanRetrieveTheRightViewControllerTypeForDeeplink() {
        let deeplink = "test://mock/2341234"
        let type = moduleManager.viewControllerType(fromDeeplink: deeplink)
        XCTAssert(type == MockDeeplinkable.classForDeeplinkingViewController())
    }
    
    func testThatItCanFailRetrievingDeeplinkableClass() {
        let deeplink = "test://failing/deeplink"
        let type = moduleManager.viewControllerType(fromDeeplink: deeplink)
        XCTAssertNil(type)
    }
    
    func testItCanGetAViewControllerForDeeplink() {
        let deeplink = "test://mock/2341234"
        guard let viewController = moduleManager.viewController(fromDeeplink: deeplink, userInfo: nil) else {
            XCTFail()
            return
        }
        XCTAssert(type(of: viewController) == MockDeeplinkable.classForDeeplinkingViewController())
    }
    
    func testItCanFailRetrievingAViewController() {
        let deeplink = "test://failing/deeplink"
        let viewController = moduleManager.viewController(fromDeeplink: deeplink, userInfo: nil)
        XCTAssertNil(viewController)
    }
    
    func testItCanReturnRemaindersForSmartDeeplinks() {
        let deeplink = "test://mock/2341234/product/1234"
        let expectedRemainder = "test://product/1234"
        
        let remainder = moduleManager.unmatchedDeeplinkRemainder(fromDeeplink: deeplink)
        XCTAssertNotNil(remainder)
        XCTAssertEqual(remainder, expectedRemainder)
    }
}
