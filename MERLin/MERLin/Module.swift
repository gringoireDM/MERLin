//
//  Module.swift
//  Module
//
//  Created by Giuseppe Lanza on 05/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public enum ViewControllerEvent: EventProtocol, Equatable {
    case uninitialized
    case initialized
    case appeared
    case disappeared
    
    case newViewController((UIViewController & PageRepresenting)?, events: Observable<ViewControllerEvent>)
    
    public static func == (lhs: ViewControllerEvent, rhs: ViewControllerEvent) -> Bool {
        switch (lhs, rhs) {
        case (.uninitialized, .uninitialized),
             (.initialized, .initialized),
             (.appeared, .appeared),
             (.disappeared, .disappeared): return true
        case let (.newViewController(lhsController, _), .newViewController(rhsController, _)):
            guard let lhsVC = lhsController, let rhsVC = rhsController else { return false }
            return lhsVC == rhsVC
        default: return false
        }
    }
}

public protocol PageRepresenting: class {
    var pageName: String { get }
    var section: String { get }
    var pageType: String { get }
}

public protocol AnyModule: class, NSObjectProtocol {
    var viewControllerEvent: Observable<ViewControllerEvent> { get }
    var routingContext: String { get }
    
    func unmanagedRootViewController() -> UIViewController
}

public protocol ModuleProtocol: AnyModule {
    associatedtype Context: AnyModuleContextProtocol
    var context: Context { get }
    
    init(usingContext buildContext: Context)
}

public extension ModuleProtocol {
    public var routingContext: String { return context.routingContext }
}

private class ViewControllerWrapper {
    weak var controller: UIViewController?
    init(controller: UIViewController) { self.controller = controller }
}

private var viewControllerEventHandle: UInt8 = 0
private var viewControllerHandle: UInt8 = 0
private var disposeBagHandle: UInt8 = 0
public extension AnyModule {
    public internal(set) var rootViewController: UIViewController? {
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
    
    public var viewControllerEvent: Observable<ViewControllerEvent> { return _viewControllerEvent }
    private var _viewControllerEvent: BehaviorSubject<ViewControllerEvent> {
        guard let observable = objc_getAssociatedObject(self, &viewControllerEventHandle) as? BehaviorSubject<ViewControllerEvent> else {
            let observable = BehaviorSubject<ViewControllerEvent>(value: .uninitialized)
            objc_setAssociatedObject(self, &viewControllerEventHandle, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return observable
        }
        return observable
    }
    
    public var disposeBag: DisposeBag {
        guard let bag = objc_getAssociatedObject(self, &disposeBagHandle) as? DisposeBag else {
            let bag = DisposeBag()
            objc_setAssociatedObject(self, &disposeBagHandle, bag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bag
        }
        return bag
    }
    
    public func prepareRootViewController() -> UIViewController {
        guard rootViewController == nil else { return rootViewController! }
        let controller = unmanagedRootViewController()
        rootViewController = controller
        _viewControllerEvent.onNext(.initialized)
        bindViewController(controller, to: _viewControllerEvent)
        return controller
    }
    
    private func bindViewController(_ viewController: UIViewController, to events: BehaviorSubject<ViewControllerEvent>) {
        let didAppearProducer = (viewController as UIViewController).rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .map { _ in ViewControllerEvent.appeared }
        
        let didDisappearProducer = (viewController as UIViewController).rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .map { _ in ViewControllerEvent.disappeared }
        
        Observable.of(didAppearProducer, didDisappearProducer)
            .merge()
            .bind(to: events)
            .disposed(by: disposeBag)
    }
    
    /// Call this function to send an event to all your listeners to notify that an internal routing is happening
    /// for the current module.
    public func trackViewController(viewController: UIViewController & PageRepresenting) {
        let events = BehaviorSubject<ViewControllerEvent>(value: .initialized)
        bindViewController(viewController, to: events)
        
        weak var weakController = viewController
        _viewControllerEvent.onNext(.newViewController(weakController, events: events))
    }
}
