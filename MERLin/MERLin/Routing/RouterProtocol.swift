//
//  RouterProtocol.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import os.log
import RxSwift

public typealias ViewControllersFactory = ViewControllerBuilding & DeeplinkManaging

public protocol Routing {
    var router: Router { get }
}

public protocol Router: AnyObject {
    var viewControllersFactory: ViewControllersFactory? { get }
    var topViewController: UIViewController { get }
    var disposeBag: DisposeBag { get }
    
    var closeButtonString: String { get }
    /**
     This method has the duty to return the right rootViewController depending on launching options. If there is a deeplink,
     this method should catch it and adjust the rootviewcontroller stack accordingly.
     
     - parameter launchOptions: The launch options returned in the appDidFinishLaunching app delegate method.
     
     - returns: The viewController stack based on the current launch options.
     */
    func rootViewController(forLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> UIViewController?
    
    /**
     This method should be used to navigate through different routing paths.
     
     - parameter routingStep: The destination routingStep.
     */
    @discardableResult func route(to destination: PresentableRoutingStep) -> UIViewController?
    @discardableResult func route(to viewController: UIViewController, withPresentationMode mode: RoutingStepPresentationMode, animated: Bool) -> UIViewController?
    
    @discardableResult func route(toDeeplink deeplink: String, userInfo: [String: Any]?) -> [UIViewController]?
    @discardableResult func route(toDeeplink deeplink: String, shouldPush: Bool, userInfo: [String: Any]?) -> [UIViewController]?
    @discardableResult func route(toDeeplink deeplink: String, traverseAll: Bool, userInfo: [String: Any]?) -> [UIViewController]?
    @discardableResult func route(toDeeplink deeplink: String, shouldPush: Bool, traverseAll: Bool, userInfo: [String: Any]?) -> [UIViewController]?
    
    func handleShortcutItem(_ item: UIApplicationShortcutItem)
    
    func showLoadingView()
    func hideLoadingView()
}

// MARK: Route to...

public extension Router {
    var closeButtonString: String { return "Close" }
    internal func currentViewController() -> UIViewController {
        var currentController = topViewController
        while let presented = currentController.presentedViewController {
            currentController = presented
        }
        return currentController
    }
    
    @discardableResult func route(to viewController: UIViewController, withPresentationMode mode: RoutingStepPresentationMode, animated: Bool) -> UIViewController? {
        if case let .embed(info) = mode {
            // We can avoid to compute the topController in this case
            os_log("Embedding %@ in %@", log: .router, type: .debug, viewController, info.parentController)
            return embed(viewController: viewController, embedInfo: info)
        }
        
        var topController = currentViewController()
        if let selectedController = (topController as? UITabBarController)?.selectedViewController {
            topController = selectedController
        }
        
        os_log("Showing %@ with presentation mode %@", log: .router, type: .debug, viewController, mode.description)
        
        switch mode {
        case let .push(closeButton, onClose):
            if closeButton {
                viewController.navigationItem.leftBarButtonItem = self.closeButton(for: viewController, onClose: onClose)
            }
            guard let navController = topController as? UINavigationController else {
                os_log("Could not push %@. Presenting it instead", log: .router, type: .fault, viewController)
                topController.present(viewController, animated: animated, completion: nil)
                return viewController
            }
            navController.pushViewController(viewController, animated: animated)
        case let .modal(style):
            viewController.modalPresentationStyle = style
            topController.present(viewController, animated: animated, completion: nil)
        case let .modalWithNavigation(style, closeButton, onClose):
            let navigationController = UINavigationController(rootViewController: viewController)
            if closeButton {
                viewController.navigationItem.leftBarButtonItem = self.closeButton(for: viewController, onClose: onClose)
            }
            navigationController.modalPresentationStyle = style
            topController.present(navigationController, animated: animated, completion: nil)
        case .embed, .none: return viewController
        }
        
        return viewController
    }
    
    @discardableResult func route(to destination: PresentableRoutingStep) -> UIViewController? {
        guard let viewControllersFactory = viewControllersFactory else { return nil }
        let viewController = viewControllersFactory.viewController(for: destination)
        os_log("got %@ for routing step: %@", log: .router, type: .debug, viewController, destination.description)
        return route(to: viewController, withPresentationMode: destination.presentationMode, animated: destination.animated)
    }
    
    func embed(viewController: UIViewController, embedInfo: (UIViewController, UIView)) -> UIViewController? {
        let (parentController, container) = embedInfo
        guard let embeddedView = viewController.view else { return nil }
        viewController.willMove(toParent: parentController)
        parentController.addChild(viewController)
        embeddedView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(embeddedView)
        NSLayoutConstraint.activate([
            embeddedView.topAnchor.constraint(equalTo: container.topAnchor),
            embeddedView.rightAnchor.constraint(equalTo: container.rightAnchor),
            embeddedView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            embeddedView.leftAnchor.constraint(equalTo: container.leftAnchor)
        ])
        viewController.didMove(toParent: parentController)
        return viewController
    }
    
    private func closeButton(for viewController: UIViewController, onClose: (() -> Void)?) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: closeButtonString, style: .plain, target: nil, action: nil)
        button.rx.tap.subscribe(onNext: { [unowned viewController] in
            os_log("%@ dismissed using MERLin close button", log: .router, type: .info, viewController)
            viewController.dismiss(animated: true, completion: onClose)
        }).disposed(by: disposeBag)
        return button
    }
}

// MARK: Deeplink

public extension Router {
    @discardableResult func route(toDeeplink deeplink: String, userInfo: [String: Any]?) -> [UIViewController]? {
        return handleDeeplink(deeplink, shouldPush: false, traverseAll: true, userInfo: userInfo)
    }
    
    @discardableResult func route(toDeeplink deeplink: String, shouldPush: Bool, userInfo: [String: Any]?) -> [UIViewController]? {
        return handleDeeplink(deeplink, shouldPush: shouldPush, traverseAll: true, userInfo: userInfo)
    }
    
    @discardableResult func route(toDeeplink deeplink: String, traverseAll: Bool, userInfo: [String: Any]?) -> [UIViewController]? {
        return handleDeeplink(deeplink, shouldPush: false, traverseAll: traverseAll, userInfo: userInfo)
    }
    
    @discardableResult func route(toDeeplink deeplink: String, shouldPush: Bool, traverseAll: Bool, userInfo: [String: Any]?) -> [UIViewController]? {
        return handleDeeplink(deeplink, shouldPush: shouldPush, traverseAll: traverseAll, userInfo: userInfo)
    }
    
    /**
     This particular implementation of deeplink handling search for the type of the viewController
     to be deeplinked just on top of the stack. If the from parameter is not nil, then the from
     viewController will be the one considered "top of the stack". If the controller is of the
     right type, then the controller is updated using the deeplink as update context.
     
     If the controller is not found, a new controller is instantiated, wrapped in a
     navigationcontroller and presented modally on the stack.
     
     If the shouldPush parameter is true and the "top of the stack" viewController is a
     navigationController, then the deeplinked viewController will be pushed.
     
     - parameter deeplink: The deeplink to handle
     - parameter from: The viewController to be considered "top of the stack". If nil, the current
     view controller will be computed in runtime.
     - parameter shouldPush: Determine if the deeplinked viewController should be pushed or presented
     modally in case the "top of the stack" viewController is an UINavigationController. Should push
     also ignores updatable controllers, unless the deeplink is not updatable itself from the current deeplink
     - parameter traverseAll: Determine if the updatable view controller should be searched in depth
     in case of nesting of containers in the currently visible view controller. Specifically, in case of a tab bar controller
     containing for each controller a navigation controller. With this parameter as false the search would stop to the
     navigation controller, while with true the search will inspect the view controllers contained in the navigation controller also
     */
    @discardableResult
    private func handleDeeplink(_ deeplink: String, from: UIViewController? = nil, shouldPush: Bool = false, traverseAll: Bool = false, userInfo: [String: Any]?) -> [UIViewController]? {
        guard let viewControllersFactory = viewControllersFactory,
            let controllerClass = viewControllersFactory.viewControllerType(fromDeeplink: deeplink) else {
            os_log("🔗 Could not find a responder for deeplink %@", log: .router, type: .debug, deeplink)
            return nil
        }
        
        os_log("🔗 Found responder for deeplink (%@), searching for a controller of type %@",
               log: .router, type: .debug, deeplink, String(describing: controllerClass))
        
        // First check on top of the stack
        var currentController = from ?? currentViewController()
        
        var handled = false
        var deeplinkedController: UIViewController?
        let controllers = (currentController as? UITabBarController)?.viewControllers?.enumerated() ?? [currentController].enumerated()
        for (i, controller) in controllers {
            if controller.isMember(of: controllerClass) {
                handled = viewControllersFactory.update(viewController: controller, fromDeeplink: deeplink, userInfo: userInfo)
                deeplinkedController = controller
                os_log("🔗 Found controller candidate for deeplink %@: %@ the controller was %@updated",
                       log: .router, type: .debug, deeplink, controller, handled ? "" : "not ")
            } else if !shouldPush || traverseAll || controller == (currentController as? UITabBarController)?.selectedViewController,
                let contained = (controller as? UINavigationController)?.viewControllers.last,
                contained.isMember(of: controllerClass) {
                // currentController might be a navigation controller (most likely) containing the controller class
                handled = viewControllersFactory.update(viewController: contained, fromDeeplink: deeplink, userInfo: userInfo)
                deeplinkedController = contained
                os_log("🔗 Found controller candidate for deeplink %@: %@ the controller was %@updated",
                       log: .router, type: .debug, deeplink, contained, handled ? "" : "not ")
            }
            
            if handled {
                (currentController as? UITabBarController)?.selectedIndex = i
                break
            }
        }
        
        // The update method can fail. If for any reason we were not able to find a controller, or to update it
        // we want to fallback on the default present/push logic
        if !handled {
            guard let deeplinkedViewController = viewControllersFactory.viewController(fromDeeplink: deeplink, userInfo: userInfo) else {
                os_log("🔗 Could not create a controller for the deeplink %@ expected a view controller given that a responder exists.",
                       log: .router, type: .fault, deeplink)
                return nil
            }
            os_log("🔗 Obtained a new viewController for deeplink %@ : %@", log: .router, type: .debug, deeplink, deeplinkedViewController)
            var animated = false
            
            #if !TEST
                if UIApplication.shared.applicationState == .active {
                    animated = true
                }
            #endif
            
            if shouldPush,
                let navigationController = currentController as? UINavigationController ??
                (currentController as? UITabBarController)?.selectedViewController as? UINavigationController {
                navigationController.pushViewController(deeplinkedViewController, animated: animated)
                
                os_log("🔗 Pushed view controller %@ for deeplink %@", log: .router, type: .debug, deeplinkedViewController, deeplink)
            } else {
                if shouldPush {
                    os_log("🔗 Could not push as the current view controller (%@) is not a navigation controller and does not contain a navigation controller",
                           log: .router, type: .debug, currentController)
                }
                let navigationController = UINavigationController(rootViewController: deeplinkedViewController)
                
                currentController.present(navigationController, animated: animated, completion: nil)
                
                deeplinkedViewController.navigationItem.leftBarButtonItem = closeButton(for: deeplinkedViewController, onClose: nil)
                currentController = navigationController
                os_log("🔗 Presenting %@ modally in a new navigation controller for deeplink %@",
                       log: .router, type: .debug, deeplinkedViewController, deeplink)
            }
            
            deeplinkedController = deeplinkedViewController
        }
        
        return (deeplinkedController.map { [$0] } ?? []) + (pushUnmatched(fromDeeplink: deeplink, from: currentController, userInfo: userInfo) ?? [])
    }
    
    /// If the deeplink is composed by a part that was not matched by the deeplinked controller
    /// there might be a next deeplink path. Ex: thebay://productarray/1234/pdp/112233
    /// would cause product array to match the first part, and to have `/pdp/112233` unmatched
    /// a new deeplink is then generated in this method to be theBay://pdp/112233 and then pushed
    @discardableResult
    func pushUnmatched(fromDeeplink deeplink: String, from: UIViewController?, userInfo: [String: Any]?) -> [UIViewController]? {
        guard let newDeeplink = viewControllersFactory?.unmatchedDeeplinkRemainder(fromDeeplink: deeplink) else {
            return nil
        }
        os_log("🔗 Deeplink %@ was routed and has a remainder formed by a contiguous portion of the url not consumed by the responder: %@",
               log: .router, type: .debug, deeplink, newDeeplink)
        return handleDeeplink(newDeeplink, from: from, shouldPush: true, traverseAll: false, userInfo: userInfo)
    }
}
