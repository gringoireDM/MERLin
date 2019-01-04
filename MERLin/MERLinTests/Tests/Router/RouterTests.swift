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
}
