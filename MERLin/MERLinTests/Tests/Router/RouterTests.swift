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
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .push(withCloseButton: .none),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(root.viewControllers.last, expected)
        XCTAssertNil(root.viewControllers.last?.navigationItem.leftBarButtonItem)
    }
    
    func testRouteToPushWithCloseButton() {
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .push(withCloseButton: .title("Close", onClose: nil)),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(root.viewControllers.last, expected)
        XCTAssertNotNil(root.viewControllers.last?.navigationItem.leftBarButtonItem)
    }
    
    func testRouteToPushWithCloseButtonImage() {
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .push(withCloseButton: .image(UIImage(), onClose: nil)),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(root.viewControllers.last, expected)
        XCTAssertNotNil(root.viewControllers.last?.navigationItem.leftBarButtonItem)
    }
    
    func testFailToPush() {
        let topController = UIViewController()
        router.topViewController = topController
        
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .push(withCloseButton: .none),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(topController.presentedViewController, expected)
    }
    
    func testRouteToModal() {
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .modal(modalPresentationStyle: .fullScreen),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(root.presentedViewController, expected)
    }
    
    func testRouteToModalWithNavigationWithoutCloseButton() {
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .modalWithNavigation(modalPresentationStyle: .fullScreen,
                                                   withCloseButton: .none),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssert(root.presentedViewController is UINavigationController)
        XCTAssertEqual(root.presentedViewController?.children.first, expected)
        XCTAssertNil(root.presentedViewController?.children.first?.navigationItem.leftBarButtonItem)
    }
    
    func testRouteToModalWithNavigationWithCloseButton() {
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .modalWithNavigation(modalPresentationStyle: .fullScreen,
                                                   withCloseButton: .title("Close", onClose: nil)),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssert(root.presentedViewController is UINavigationController)
        XCTAssertEqual(root.presentedViewController?.children.first, expected)
        XCTAssertNotNil(root.presentedViewController?.children.first?.navigationItem.leftBarButtonItem)
    }
    
    func testRouteToModalWithNavigationWithCloseButtonImage() {
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .modalWithNavigation(modalPresentationStyle: .fullScreen,
                                                   withCloseButton: .image(UIImage(), onClose: nil)),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssert(root.presentedViewController is UINavigationController)
        XCTAssertEqual(root.presentedViewController?.children.first, expected)
        XCTAssertNotNil(root.presentedViewController?.children.first?.navigationItem.leftBarButtonItem)
    }
    
    func testEmbed() {
        let topController = UIViewController()
        router.topViewController = topController
        
        let step = PresentableRoutingStep(
            withStep: .mock(),
            presentationMode: .embed(parentController: topController,
                                     containerView: topController.view),
            animated: false
        )
        let expected = router.route(to: step)
        XCTAssertNotNil(expected)
        XCTAssertEqual(topController.children.first, expected)
        XCTAssertEqual(topController.view.subviews.first, expected?.view)
    }
    
    func testSimpleDeeplink() {
        let deeplink = "test://mock/"
        let controllers = router.route(toDeeplink: deeplink, userInfo: nil)
        XCTAssertEqual(controllers.count, 1)
        XCTAssert(controllers.first is MockViewController)
        XCTAssertEqual(controllers.first, (router.currentViewController() as? UINavigationController)?.viewControllers.last)
    }
    
    func testSmartDeeplink() {
        let deeplink = "test://mock/product/1234"
        let controllers = router.route(toDeeplink: deeplink, userInfo: nil)
        
        XCTAssertEqual(controllers.count, 2)
    }
    
    func setupTabBarRootViewController() -> (MockRouter, MockDeeplinkable, LowPriorityMockDeeplinkableModule, LowPriorityMockDeeplinkableModule) {
        let mockDeeplinkable = MockDeeplinkable(usingContext: ModuleContext(building: MockDeeplinkable.self))
        let viewController = UINavigationController(rootViewController: moduleManager.setup((mockDeeplinkable, mockDeeplinkable.prepareRootViewController())))
        
        let module = LowPriorityMockDeeplinkableModule(usingContext: ModuleContext(building: LowPriorityMockDeeplinkableModule.self))
        let updatableViewController = UINavigationController(rootViewController: moduleManager.setup((module, module.prepareRootViewController())))
        
        let updatableWithoutNavigationModule = LowPriorityMockDeeplinkableModule(usingContext: ModuleContext(building: LowPriorityMockDeeplinkableModule.self))
        let updatableWithoutNavigation = moduleManager.setup((updatableWithoutNavigationModule, updatableWithoutNavigationModule.prepareRootViewController()))
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([viewController, updatableViewController, updatableWithoutNavigation], animated: false)
        let tabBarRouter = MockRouter(withRootViewController: tabBarController)
        tabBarRouter.viewControllersFactory = moduleManager
        
        return (tabBarRouter, mockDeeplinkable, module, updatableWithoutNavigationModule)
    }
    
    func testItCanDeeplinkFromTabBarController() {
        let (tabBarRouter, _, _, _) = setupTabBarRootViewController()
        
        let deeplink = "test://mock/"
        let controllers = tabBarRouter.route(
            toDeeplink: deeplink,
            behaviour: DeeplinkBehaviour(presentationStyle: .alwaysModally,
                                         updatableSearchPreference: .traverseAll,
                                         shouldFollowRemainder: true),
            userInfo: nil
        )
        
        XCTAssert(controllers.first is MockViewController)
        XCTAssertEqual(controllers, (tabBarRouter.currentViewController() as? UINavigationController)?.viewControllers)
    }
    
    func testItCanFindUpdatableModuleInTabBarViewController() {
        let (tabBarRouter, _, updatable, _) = setupTabBarRootViewController()
        
        let deeplink = "test://product/1234"
        let controllers = tabBarRouter.route(toDeeplink: deeplink, userInfo: nil)
        
        guard let tabbarController = tabBarRouter.topViewController as? UITabBarController else {
            XCTFail("At this point this controller should be a tab bar")
            return
        }
        
        XCTAssertEqual(controllers, (tabbarController.selectedViewController as? UINavigationController)?.viewControllers)
        XCTAssertEqual(tabbarController.selectedIndex, 1)
        XCTAssertEqual((tabbarController.selectedViewController as? UINavigationController)?.viewControllers, [updatable.rootViewController!])
    }
    
    func testItCanFindUpdatableModuleInTabBarViewControllerWhenItsNotInNavBar() {
        let (tabBarRouter, _, _, updatable) = setupTabBarRootViewController()
        
        let deeplink = "test://product/1234"
        
        guard let tabbarController = tabBarRouter.topViewController as? UITabBarController else {
            XCTFail("At this point this controller should be a tab bar")
            return
        }
        
        tabbarController.selectedIndex = 2
        
        let controllers = tabBarRouter.route(
            toDeeplink: deeplink,
            behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                         updatableSearchPreference: .justInCurrentContext,
                                         shouldFollowRemainder: false),
            userInfo: nil
        )
        
        XCTAssertEqual(controllers, [tabbarController.selectedViewController!])
        XCTAssertEqual(tabbarController.selectedIndex, 2)
        XCTAssertEqual(tabbarController.selectedViewController, updatable.rootViewController!)
    }
    
    func testItCanPushFromCurrentContext() {
        let deeplink = "test://mock/"
        let controllers = router.route(
            toDeeplink: deeplink,
            behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                         updatableSearchPreference: .justInCurrentContext,
                                         shouldFollowRemainder: false),
            userInfo: nil
        )
        
        XCTAssertEqual((router.topViewController as? UINavigationController)?.viewControllers.count, 2)
        XCTAssertEqual(controllers.first, (router.topViewController as? UINavigationController)?.viewControllers.last)
    }
    
    func testItCanRejectPushAndFallbackOnModal() {
        router.topViewController = UIViewController()
        let deeplink = "test://mock/"
        let controllers = router.route(
            toDeeplink: deeplink,
            behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                         updatableSearchPreference: .justInCurrentContext,
                                         shouldFollowRemainder: false),
            userInfo: nil
        )
        
        XCTAssertEqual((router.topViewController.presentedViewController as? UINavigationController)?.viewControllers.last, controllers.first)
    }
    
    func testItCanFailPushForMissingNavigationController() {
        let deeplink = "test://mock/noPush"
        let controllers = router.route(
            toDeeplink: deeplink,
            behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                         updatableSearchPreference: .justInCurrentContext,
                                         shouldFollowRemainder: false),
            userInfo: nil
        )
        
        XCTAssertEqual((router.topViewController as? UINavigationController)?.viewControllers.count, 1)
        XCTAssertEqual((router.topViewController.presentedViewController as? UINavigationController)?.viewControllers.last, controllers.first)
    }
    
    func testItCanPushFromCurrentContextInTabBarViewController() {
        let (tabBarRouter, _, _, _) = setupTabBarRootViewController()
        
        let deeplink = "test://mock/"
        
        guard let tabbarController = tabBarRouter.topViewController as? UITabBarController else {
            XCTFail("At this point this controller should be a tab bar")
            return
        }
        
        tabbarController.viewControllers = Array(tabbarController.viewControllers?[0 ... 1] ?? [])
        
        for index in 0 ..< (tabbarController.viewControllers?.count ?? 0) {
            tabbarController.selectedIndex = index
            XCTAssertEqual((tabbarController.selectedViewController as? UINavigationController)?.viewControllers.count, 1)
            
            let controllers = tabBarRouter.route(
                toDeeplink: deeplink,
                behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                             updatableSearchPreference: .justInCurrentContext,
                                             shouldFollowRemainder: false),
                userInfo: nil
            )
            
            XCTAssertEqual(controllers.first, (tabbarController.selectedViewController as? UINavigationController)?.viewControllers.last)
            XCTAssertEqual((tabbarController.selectedViewController as? UINavigationController)?.viewControllers.count, 2)
        }
    }
    
    func testItCanSmartDeeplinkFromCurrentContext() {
        let (tabBarRouter, _, _, _) = setupTabBarRootViewController()
        let deeplink = "test://mock/product/1234"
        
        guard let tabbarController = tabBarRouter.topViewController as? UITabBarController else {
            XCTFail("At this point this controller should be a tab bar")
            return
        }
        
        tabbarController.viewControllers = Array(tabbarController.viewControllers?[0 ... 1] ?? [])
        
        let controllers = tabBarRouter.route(
            toDeeplink: deeplink,
            behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                         updatableSearchPreference: .justInCurrentContext,
                                         shouldFollowRemainder: true),
            userInfo: nil
        )
        
        XCTAssertEqual(controllers, (tabbarController.selectedViewController as? UINavigationController)?.viewControllers.suffix(2))
        XCTAssertEqual(tabbarController.selectedIndex, 0)
        XCTAssertEqual((tabbarController.selectedViewController as? UINavigationController)?.viewControllers.count, 3)
    }
    
    func testItCanFailDeeplinking() {
        let deeplink = "test://frank/sinatra"
        let controllers = router.route(
            toDeeplink: deeplink,
            behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                         updatableSearchPreference: .justInCurrentContext,
                                         shouldFollowRemainder: false),
            userInfo: nil
        )
        XCTAssert(controllers.isEmpty)
    }
}
