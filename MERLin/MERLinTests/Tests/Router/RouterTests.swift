//
//  RouterTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 26/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import XCTest

class RouterTests: XCTestCase {
    var router: MockRouter!
    var root: UINavigationController!
    var moduleManager: BaseModuleManager!
    
    override func setUp() {
        moduleManager = BaseModuleManager()
        root = UINavigationController(rootViewController: UIViewController())
        router = MockRouter(withRootViewController: root)
        router.viewControllersFactory = moduleManager
    }
    
    override func tearDown() {
        router = nil
        root = nil
        moduleManager = nil
    }
    
    func testCurrentViewController() {
        let current = router.currentViewController()
        XCTAssertEqual(current, router.topViewController)
    }
    
    func testCurrentViewControllerWithPresentedController() {
        let expectedCurrent = UIViewController()
        router.topViewController.present(expectedCurrent, animated: false)
        let current = router.currentViewController()
        XCTAssertEqual(current, expectedCurrent)
    }
    
    func testCurrentViewControllerWithChildPresenting() {
        let expectedCurrent = UIViewController()
        router.topViewController.children.first?.present(expectedCurrent, animated: false)
        let current = router.currentViewController()
        XCTAssertEqual(current, expectedCurrent)
    }
    
    func testRoutToPushWithoutCloseButton() {
        let step = PresentableRoutingStep(withStep: .mock(), presentationMode: .push(withCloseButton: false, onClose: nil), animated: false)
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(root.viewControllers.last, expected)
        XCTAssertNil(root.viewControllers.last?.navigationItem.leftBarButtonItem)
    }
    
    func testRoutToPushWithCloseButton() {
        let step = PresentableRoutingStep(withStep: .mock(), presentationMode: .push(withCloseButton: true, onClose: nil), animated: false)
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(root.viewControllers.last, expected)
        XCTAssertNotNil(root.viewControllers.last?.navigationItem.leftBarButtonItem)
    }
    
    func testFailToPush() {
        let topController = UIViewController()
        router.topViewController = topController
        
        let step = PresentableRoutingStep(withStep: .mock(), presentationMode: .push(withCloseButton: false, onClose: nil), animated: false)
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(topController.presentedViewController, expected)
    }
    
    func testRouteToModal() {
        let step = PresentableRoutingStep(withStep: .mock(), presentationMode: .modal(modalPresentationStyle: .fullScreen), animated: false)
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(root.presentedViewController, expected)
    }
    
    func testRouteToModalWithNavigationWithoutCloseButton() {
        let step = PresentableRoutingStep(withStep: .mock(), presentationMode: .modalWithNavigation(modalPresentationStyle: .fullScreen, withCloseButton: false, onClose: nil), animated: false)
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssert(root.presentedViewController is UINavigationController)
        XCTAssertEqual(root.presentedViewController?.children.first, expected)
        XCTAssertNil(root.presentedViewController?.children.first?.navigationItem.leftBarButtonItem)
    }
    
    func testRouteToModalWithNavigationWithCloseButton() {
        let step = PresentableRoutingStep(withStep: .mock(), presentationMode: .modalWithNavigation(modalPresentationStyle: .fullScreen, withCloseButton: true, onClose: nil), animated: false)
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssert(root.presentedViewController is UINavigationController)
        XCTAssertEqual(root.presentedViewController?.children.first, expected)
        XCTAssertNotNil(root.presentedViewController?.children.first?.navigationItem.leftBarButtonItem)
    }
    
    func testEmbed() {
        let topController = UIViewController()
        router.topViewController = topController
        
        let step = PresentableRoutingStep(withStep: .mock(), presentationMode: .embed(parentController: topController, containerView: topController.view), animated: false)
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(topController.children.first, expected)
        XCTAssertEqual(topController.view.subviews.first, expected?.view)
    }
    
    func testSimpleDeeplink() {
        let deeplink = "test://mock/"
        let controller = router.route(toDeeplink: deeplink)
        
        XCTAssert(controller is UINavigationController)
        XCTAssert((controller as? UINavigationController)?.viewControllers.first is MockViewController)
    }
    
    func testSmartDeeplink() {
        let deeplink = "test://mock/product/1234"
        let controller = router.route(toDeeplink: deeplink)
        
        XCTAssertEqual((controller as? UINavigationController)?.viewControllers.count, 2)
    }
    
    func setupTabBarRootViewController() -> (MockRouter, MockDeeplinkable, LowPriorityMockDeeplinkableModule) {
        let mockDeeplinkable = MockDeeplinkable(usingContext: ModuleContext(building: MockDeeplinkable.self))
        let viewController = UINavigationController(rootViewController: moduleManager.setup((mockDeeplinkable, mockDeeplinkable.prepareRootViewController())))
        
        let module = LowPriorityMockDeeplinkableModule(usingContext: ModuleContext(building: LowPriorityMockDeeplinkableModule.self))
        let updatableViewController = UINavigationController(rootViewController: moduleManager.setup((module, module.prepareRootViewController())))
        
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([viewController, updatableViewController], animated: false)
        let tabBarRouter = MockRouter(withRootViewController: tabBarController)
        tabBarRouter.viewControllersFactory = moduleManager
        
        return (tabBarRouter, mockDeeplinkable, module)
    }
    
    func testItCanDeeplinkFromTabBarController() {
        let (tabBarRouter, _, _) = setupTabBarRootViewController()
        
        let deeplink = "test://mock/"
        let controller = tabBarRouter.route(toDeeplink: deeplink)
        
        XCTAssert(controller is UINavigationController)
        XCTAssert((controller as? UINavigationController)?.viewControllers.first is MockViewController)
    }
    
    func testItCanFindUpdatableModuleInTabBarViewController() {
        let (tabBarRouter, _, updatable) = setupTabBarRootViewController()
        
        let deeplink = "test://product/1234"
        let controller = tabBarRouter.route(toDeeplink: deeplink)
        
        XCTAssertEqual(controller, tabBarRouter.topViewController)
        XCTAssertEqual((controller as? UITabBarController)?.selectedIndex, 1)
        XCTAssertEqual(((controller as? UITabBarController)?.selectedViewController as? UINavigationController)?.viewControllers, [updatable.rootViewController!])
    }
    
    func testItCanPushFromCurrentContext() {
        let deeplink = "test://mock/"
        let controller = router.handleDeeplink(deeplink, shouldPush: true)
        
        XCTAssertEqual(controller, router.topViewController)
        XCTAssertEqual((controller as? UINavigationController)?.viewControllers.count, 2)
    }
    
    func testItCanPushFromCurrentContextInTabBarViewController() {
        let (tabBarRouter, _, _) = setupTabBarRootViewController()
        
        let deeplink = "test://mock/"
        
        guard let tabbarController = tabBarRouter.topViewController as? UITabBarController else {
            XCTFail("At this point this controller should be a tab bar")
            return
        }
        
        for index in 0 ..< (tabbarController.viewControllers?.count ?? 0) {
            tabbarController.selectedIndex = index
            XCTAssertEqual((tabbarController.selectedViewController as? UINavigationController)?.viewControllers.count, 1)
            
            let controller = tabBarRouter.handleDeeplink(deeplink, shouldPush: true)
            
            XCTAssertEqual(controller, tabbarController)
            XCTAssertEqual((tabbarController.selectedViewController as? UINavigationController)?.viewControllers.count, 2)
        }
    }
    
    func testItCanSmartDeeplinkFromCurrentContext() {
        let (tabBarRouter, mock, updatable) = setupTabBarRootViewController()
        let deeplink = "test://mock/product/1234"
        
        let controller = tabBarRouter.handleDeeplink(deeplink, shouldPush: true)
        
        XCTAssertEqual(controller, tabBarRouter.topViewController)
        XCTAssertEqual((controller as? UITabBarController)?.selectedIndex, 0)
        XCTAssertEqual(((controller as? UITabBarController)?.selectedViewController as? UINavigationController)?.viewControllers.count, 3)
    }
}
