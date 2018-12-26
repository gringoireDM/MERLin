//
//  RouterProtocol.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public typealias ViewControllersFactory = ViewControllerBuilding&DeeplinkManaging

public protocol Routing {
    var router: Router { get }
}

public protocol Router: class {
    var viewControllersFactory: ViewControllersFactory? { get }
    var topViewController: UIViewController { get }
    var disposeBag: DisposeBag { get }
    
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
    
    @discardableResult func route(toDeeplink deeplink: String) -> UIViewController?
    
    func handleShortcutItem(_ item: UIApplicationShortcutItem)
    
    func showLoadingView()
    func hideLoadingView()
}

//MARK: Route to...
public extension Router {
    internal func currentViewController() -> UIViewController {
        var currentController = topViewController
        while let presented = currentController.presentedViewController {
            currentController = presented
        }
        return currentController
    }

    @discardableResult public func route(to destination: PresentableRoutingStep) -> UIViewController? {
        guard let viewControllersFactory = viewControllersFactory else { return nil }
        let viewController = viewControllersFactory.viewController(for: destination)
        
        if case let .embed(info) = destination.presentationMode {
            // We can avoid to compute the topController in this case
            return embed(viewController: viewController, embedInfo: info)
        }
        
        let topController = currentViewController()
        
        switch destination.presentationMode {
        case let .push(closeButton, onClose):
            if closeButton {
                viewController.navigationItem.leftBarButtonItem = self.closeButton(for: viewController, onClose: onClose)
            }
            guard let navController = topController as? UINavigationController else {
                topController.present(viewController, animated: destination.animated, completion: nil)
                return viewController
            }
            navController.pushViewController(viewController, animated: destination.animated)
        case let .modal(style):
            viewController.modalPresentationStyle = style
            topController.present(viewController, animated: true, completion: nil)
        case let .modalWithNavigation(style, closeButton, onClose):
            let navigationController = UINavigationController(rootViewController: viewController)
            if closeButton {
                viewController.navigationItem.leftBarButtonItem = self.closeButton(for: viewController, onClose: onClose)
            }
            navigationController.modalPresentationStyle = style
            topController.present(navigationController, animated: destination.animated, completion: nil)
        case .embed: return nil
        }
        
        return viewController
    }

    func embed(viewController: UIViewController, embedInfo: (UIViewController, UIView)) -> UIViewController? {
        let (parentController, container) = embedInfo
        guard let embeddedView = viewController.view else { return nil }
        viewController.willMove(toParent: parentController)
        parentController.addChild(viewController)
        container.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func closeButton(for viewController: UIViewController, onClose: (() ->())?) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: "Close", style: .plain, target: nil, action: nil)
        button.rx.tap.subscribe(onNext: { [unowned viewController] in
            viewController.dismiss(animated: true, completion: onClose)
        }).disposed(by: disposeBag)
        return button
    }
}

//MARK: Deeplink
public extension Router {
    
    @discardableResult public func route(toDeeplink deeplink: String) -> UIViewController? {
        return handleDeeplink(deeplink)
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
     modally in case the "top of the stack" viewController is an UINavigationController
     */
    @discardableResult
    private func handleDeeplink(_ deeplink: String, from: UIViewController? = nil, shouldPush: Bool = false) -> UIViewController? {
        guard let viewControllersFactory = viewControllersFactory,
            let controllerClass = viewControllersFactory.viewControllerType(fromDeeplink: deeplink) else {
                print("Could not open deeplink: \(deeplink)")
                return nil
        }
        
        //First check on top of the stack
        var currentController = from ?? currentViewController()
        
        var handled = false
        if currentController.isMember(of: controllerClass) {
            handled = viewControllersFactory.update(viewController: currentController, fromDeeplink: deeplink)
        } else if let contained = (currentController as? UINavigationController)?.viewControllers.last,
            contained.isMember(of: controllerClass) {
            //currentController might be a navigation controller (most likely) containing the controller class
            handled = viewControllersFactory.update(viewController: contained, fromDeeplink: deeplink)
        }
        
        //The update method can fail. If for any reason we were not able to find a controller, or to update it
        //we want to fallback on the default present/push logic
        if !handled {
            guard let deeplinkedViewController = viewControllersFactory.viewController(fromDeeplink: deeplink) else {
                return nil
            }
            
            var animated = false
            if UIApplication.shared.applicationState == .active {
                animated = true
            }
            
            if shouldPush,
                let navigationController = currentController as? UINavigationController {
                navigationController.pushViewController(deeplinkedViewController, animated: animated)
            } else {
                let navigationController = UINavigationController(rootViewController: deeplinkedViewController)

                currentController.present(navigationController, animated: animated, completion: nil)
                
                deeplinkedViewController.navigationItem.leftBarButtonItem = closeButton(for: deeplinkedViewController, onClose: nil)
                currentController = navigationController
            }
        }
        
        return pushUnmatched(fromDeeplink: deeplink, from: currentController) ?? currentController
    }
    
    ///If the deeplink is composed by a part that was not matched by the deeplinked controller
    ///there might be a next deeplink path. Ex: thebay://productarray/1234/pdp/112233
    ///would cause product array to match the first part, and to have `/pdp/112233` unmatched
    ///a new deeplink is then generated in this method to be theBay://pdp/112233 and then pushed
    @discardableResult
    public func pushUnmatched(fromDeeplink deeplink: String, from: UIViewController?) -> UIViewController? {
        guard let newDeeplink = viewControllersFactory?.unmatchedDeeplinkRemainder(fromDeeplink: deeplink) else {
            return nil
        }
        
        return handleDeeplink(newDeeplink, from: from, shouldPush: true)
    }
}
