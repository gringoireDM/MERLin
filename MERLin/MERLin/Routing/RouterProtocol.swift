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

public enum ContextUpdatableSearchPreference {
    case neverSearch
    case traverseAll
    case justInCurrentContext
}

public enum DeeplinkPresentationStyle {
    case pushIfPossible
    case alwaysModally
}

public struct DeeplinkBehaviour {
    /// The style of the presentation
    public let presentationStyle: DeeplinkPresentationStyle
    /// How should an existing ViewController be searched in the current view hierarchy
    public let updatableSearchPreference: ContextUpdatableSearchPreference
    /// This determines if smart deeplinks are enabled or not for the deeplink
    public let shouldFollowRemainder: Bool
    
    public init(presentationStyle: DeeplinkPresentationStyle,
                updatableSearchPreference: ContextUpdatableSearchPreference,
                shouldFollowRemainder: Bool) {
        self.presentationStyle = presentationStyle
        self.updatableSearchPreference = updatableSearchPreference
        self.shouldFollowRemainder = shouldFollowRemainder
    }
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
    
    func route(toDeeplink deeplink: String, userInfo: [String: Any]?) -> [UIViewController]
    func route(toDeeplink deeplink: String, behaviour: DeeplinkBehaviour, userInfo: [String: Any]?) -> [UIViewController]
    
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
        destination.beforePresenting?(viewController)
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
    
    internal func closeButton(for viewController: UIViewController, onClose: (() -> Void)?) -> UIBarButtonItem {
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
    @discardableResult
    func route(toDeeplink deeplink: String, userInfo: [String: Any]?) -> [UIViewController] {
        return route(toDeeplink: deeplink,
                     behaviour: DeeplinkBehaviour(presentationStyle: .pushIfPossible,
                                                  updatableSearchPreference: .traverseAll,
                                                  shouldFollowRemainder: true),
                     userInfo: userInfo)
    }
    
    @discardableResult
    func route(toDeeplink deeplink: String, behaviour: DeeplinkBehaviour, userInfo: [String: Any]?) -> [UIViewController] {
        return handle(deeplink: deeplink, from: nil, behaviour: behaviour, userInfo: userInfo)
    }
    
    private func visit(_ controller: UIViewController, _ controllerClass: UIViewController.Type) -> UIViewController? {
        guard !controller.isMember(of: controllerClass) else { return controller }
        guard let navController = controller as? UINavigationController,
            let top = navController.viewControllers.last,
            top.isMember(of: controllerClass) else { return nil }
        return top
    }
    
    /**
     This  implementation of deeplink handling search for the type of the viewController starting from the top most viewController, if the
     `from` parameter is nil, or from the `from` view controller.
     If a responder exists for this deeplink, and a view controller is found to be of a type representing the deeplink, then the existing
     module will be asked to update its context.
     If the update is successful, then the deeplink is fulfilled and the updated view controller is returned, otherwise a new viewController
     will be instanciated to represent this deeplink. This implementation will also follow new deeplink formed by the remainder of the
     current deeplink if the `behaviour` has the smart deeplinks enabled.
     
     - parameter deeplink: The deeplink to handle
     - parameter from: The viewController to be considered "top of the stack". If nil, the current view controller will be computed
     in runtime.
     - parameter behaviour: The behavior of this deeplink
     - parameter userInfo: Any additional info to be propagated to the module when the deeplink happens.
     
     - returns: An array of deeplinked ViewController. If smart deeplinks is enabled by the behavior this deeplink might have multiple
     responders, and the unconsumed portion of the current deeplink string might form a new deeplink that has itself a responder to be
     deeplinked.
     */
    internal func handle(deeplink: String, from: UIViewController?, behaviour: DeeplinkBehaviour, userInfo: [String: Any]?) -> [UIViewController] {
        guard let viewControllersFactory = viewControllersFactory,
            let controllerClass = viewControllersFactory.viewControllerType(fromDeeplink: deeplink) else {
            os_log("🔗 Could not find a responder for deeplink %@", log: .router, type: .debug, deeplink)
            return []
        }
        
        os_log("🔗 Found responder for deeplink (%@), searching for a controller of type %@",
               log: .router, type: .debug, deeplink, String(describing: controllerClass))
        
        // First check on top of the stack
        var currentController = from ?? currentViewController()
        
        let handled: Bool
        var deeplinkedController: UIViewController?
        
        switch behaviour.updatableSearchPreference {
        case .neverSearch: handled = false
        case .justInCurrentContext:
            let controller = (currentController as? UITabBarController)
                .flatMap { $0.selectedViewController }
                .flatMap { visit($0, controllerClass) } ?? visit(currentController, controllerClass)
            handled = controller.map {
                viewControllersFactory.update(viewController: $0,
                                              fromDeeplink: deeplink,
                                              userInfo: userInfo)
            } ?? false
            
            if let controller = controller {
                os_log("🔗 Found controller candidate for deeplink %@: %@ the controller was %@updated",
                       log: .router, type: .debug, deeplink, controller, handled ? "" : "not ")
            }
            if handled { deeplinkedController = controller }
        case .traverseAll:
            let controllers = (currentController as? UITabBarController)?
                .viewControllers?.enumerated() ?? [currentController].enumerated()
            var index: Int?
            for (i, controller) in controllers {
                guard let found = visit(controller, controllerClass) else { continue }
                let updated = viewControllersFactory.update(viewController: found,
                                                            fromDeeplink: deeplink,
                                                            userInfo: userInfo)
                os_log("🔗 Found controller candidate for deeplink %@: %@ the controller was %@updated",
                       log: .router, type: .debug, deeplink, found, updated ? "" : "not ")
                guard updated else { continue }
                
                deeplinkedController = found
                index = i
                break
            }
            if let index = index, let tabBarController = currentController as? UITabBarController {
                tabBarController.selectedIndex = index
            }
            handled = index != nil
        }
        
        if !handled {
            guard let deeplinkedViewController = viewControllersFactory
                .viewController(fromDeeplink: deeplink, userInfo: userInfo) else {
                os_log("🔗 Could not create a controller for the deeplink %@ expected a view controller given that a responder exists.",
                       log: .router, type: .fault, deeplink)
                return []
            }
            os_log("🔗 Obtained a new viewController for deeplink %@ : %@",
                   log: .router, type: .debug, deeplink, deeplinkedViewController)
            var animated = false
            
            #if !TEST
                if UIApplication.shared.applicationState == .active {
                    animated = true
                }
            #endif
            
            switch behaviour.presentationStyle {
            case .pushIfPossible:
                guard viewControllersFactory.canPush(viewController: deeplinkedViewController, forDeeplink: deeplink) else {
                    os_log("🔗 Could not push as the current view controller (%@) cannot be pushed because of its module's preferences",
                           log: .router, type: .debug, currentController)
                    fallthrough
                }
                guard let navigationController = currentController as? UINavigationController ??
                    (currentController as? UITabBarController)?.selectedViewController as? UINavigationController else {
                    os_log("🔗 Could not push as the current view controller (%@) is not a navigation controller and does not contain a navigation controller",
                           log: .router, type: .debug, currentController)
                    fallthrough
                }
                navigationController.pushViewController(deeplinkedViewController, animated: animated)
                os_log("🔗 Pushed view controller %@ for deeplink %@", log: .router, type: .debug, deeplinkedViewController, deeplink)
            case .alwaysModally:
                let navigationController = UINavigationController(rootViewController: deeplinkedViewController)
                
                currentController.present(navigationController, animated: animated, completion: nil)
                
                deeplinkedViewController.navigationItem.leftBarButtonItem = closeButton(for: deeplinkedViewController, onClose: nil)
                currentController = navigationController
                os_log("🔗 Presenting %@ modally in a new navigation controller for deeplink %@",
                       log: .router, type: .debug, deeplinkedViewController, deeplink)
            }
            
            deeplinkedController = deeplinkedViewController
        }
        
        var result = deeplinkedController.map { [$0] } ?? []
        if behaviour.shouldFollowRemainder {
            result += pushUnmatched(fromDeeplink: deeplink, from: currentController, userInfo: userInfo) ?? []
        }
        return result
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
        return handle(deeplink: newDeeplink, from: from, behaviour: DeeplinkBehaviour(
            presentationStyle: .pushIfPossible,
            updatableSearchPreference: .neverSearch,
            shouldFollowRemainder: true
        ), userInfo: userInfo)
    }
}
