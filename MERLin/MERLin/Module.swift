//
//  Module.swift
//  Module
//
//  Created by Giuseppe Lanza on 05/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public protocol AnyModule: AnyObject, NSObjectProtocol {
    var routingContext: String { get }
    
    func unmanagedRootViewController() -> UIViewController
}

public protocol ModuleProtocol: AnyModule {
    associatedtype Context: AnyModuleContextProtocol
    var context: Context { get }
    
    init(usingContext buildContext: Context)
}

public extension ModuleProtocol {
    var routingContext: String { return context.routingContext }
}

private class ViewControllerWrapper: Equatable {
    static func == (lhs: ViewControllerWrapper, rhs: ViewControllerWrapper) -> Bool {
        return lhs.controller == rhs.controller
    }
    
    weak var controller: UIViewController?
    init(controller: UIViewController?) { self.controller = controller }
}

private var viewControllerHandle: UInt8 = 0
private var disposeBagHandle: UInt8 = 0
private var newWrappedViewControllerObsHandle: UInt8 = 0
private var newViewControllerObsHandle: UInt8 = 0

public extension AnyModule {
    internal(set) var rootViewController: UIViewController? {
        get {
            let wrapper = objc_getAssociatedObject(self, &viewControllerHandle) as? ViewControllerWrapper
            return wrapper?.controller
        } set {
            guard let viewController = newValue else {
                objc_setAssociatedObject(self, &viewControllerHandle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return
            }
            guard viewController != rootViewController else { return }
            let wrapper = ViewControllerWrapper(controller: viewController)
            objc_setAssociatedObject(self, &viewControllerHandle, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var disposeBag: DisposeBag {
        guard let bag = objc_getAssociatedObject(self, &disposeBagHandle) as? DisposeBag else {
            let bag = DisposeBag()
            objc_setAssociatedObject(self, &disposeBagHandle, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
        return bag
    }
    
    private var _newViewControllers: BehaviorSubject<ViewControllerWrapper> {
        guard let observable = objc_getAssociatedObject(self, &newWrappedViewControllerObsHandle) as? BehaviorSubject<ViewControllerWrapper> else {
            let initial = ViewControllerWrapper(controller: rootViewController)
            let observable = BehaviorSubject<ViewControllerWrapper>(value: initial)
            objc_setAssociatedObject(self, &newWrappedViewControllerObsHandle, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return observable
        }
        return observable
    }
    
    /// This observable notifies of new view controllers presented due to internal routing
    /// for this to work, it is necessary that as part of your internal routing system you invoke the
    /// `signalNew(viewController:)` function to emit a new event.
    /// This observable will always emit the latest signaled viewController, but it will not retain it.
    /// If the latest signaled viewController was released any new subscription will have no initial value.
    var newViewControllers: Observable<UIViewController> {
        guard let observable = objc_getAssociatedObject(self, &newViewControllerObsHandle) as? Observable<UIViewController> else {
            let observable = _newViewControllers
                .distinctUntilChanged()
                .compactMap { $0.controller }
            objc_setAssociatedObject(self, &newViewControllerObsHandle, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return observable
        }
        return observable
    }
    
    func prepareRootViewController() -> UIViewController {
        guard rootViewController == nil else { return rootViewController! }
        let controller = unmanagedRootViewController()
        rootViewController = controller
        signalNew(viewController: controller)
        return controller
    }
    
    /// This function will make sure that a new event with the new ViewController is emitted
    /// through the `newViewControllers` observable. This function does not retain the view controller
    /// as well as the observable. RootViewController is always automatically notified when the
    /// `prepareRootViewController` function is invoked.
    func signalNew(viewController: UIViewController) {
        let wrapped = ViewControllerWrapper(controller: viewController)
        _newViewControllers.onNext(wrapped)
    }
}
