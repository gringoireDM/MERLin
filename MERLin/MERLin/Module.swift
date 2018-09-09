//
//  Module.swift
//  Module
//
//  Created by Giuseppe Lanza on 05/02/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import RxSwift

public enum ViewControllerEvent: EventProtocol {
    case uninitialized
    case initialized
    case appeared
    case disappeared
}

public protocol ModuleProtocol: class, NSObjectProtocol {
    var viewControllerEvent: Observable<ViewControllerEvent> { get }
    var viewController: UIViewController { get }
    
    var context: ModuleBuildContextProtocol { get }
    
    func prepareRootViewController() -> UIViewController
}

private var viewControllerEventHandle: UInt8 = 0
private var disposeBagHandle:UInt8 = 0

public extension ModuleProtocol where Self: NSObject {
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
        _viewControllerEvent.onNext(.initialized)
        
        let didAppearProducer = viewController.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .map { _ in ViewControllerEvent.appeared }
        
        let didDisappearProducer = viewController.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .map { _ in ViewControllerEvent.disappeared }
        
        Observable.of(didAppearProducer, didDisappearProducer)
            .merge()
            .bind(to: _viewControllerEvent)
            .disposed(by: disposeBag)
        
        return viewController
    }
}

public class ThemeContainer {
    public static var defaultTheme: ModuleThemeProtocol! {
        didSet { defaultTheme.applyAppearance() }
    }
    public var theme: ModuleThemeProtocol = ThemeContainer.defaultTheme
}



//open class Module: NSObject {
//    public static var defaultRoutingContext: String = "default"
//    public static var deeplinkRoutingContext: String = "deeplink"
//
//    public static var defaultTheme: ModuleThemeProtocol! {
//        didSet {
//            defaultTheme.applyAppearance()
//        }
//    }
//
//    public static var buildABTestingManager: () -> (manager: ABTesting?, stateMachine: ABTestingManagerStateMachine?) = { return (nil, nil) }
//
//    public let disposeBag = DisposeBag()
//    public var viewControllerEvent: Observable<ViewControllerEvent> { return _viewControllerEvent }
//    private let _viewControllerEvent = BehaviorSubject<ViewControllerEvent>(value: .uninitialized)
//
//    open private(set) var viewControllerFactory: ModuleViewControllerFactory?
//    open private(set) var viewControllerTransform: ((UIViewController) -> Void)?
//
//    public private(set) var context: ModuleBuildContextProtocol
//    public var routingContext: String { return context.routingContext }
//
//    public weak var currentViewController: UIViewController?
//
//    public init(withBuildContext buildContext: ModuleBuildContextProtocol) {
//        context = buildContext
//        super.init()
//    }
//
//    open func buildRootViewController() -> UIViewController {
//        let controller = currentViewController ?? viewControllerFactory?.instantiateInitialViewController() ?? UIViewController()
//        currentViewController = controller
//        viewControllerTransform?(controller)
//
//        _viewControllerEvent.onNext(.initialized)
//
//        let didAppearProducer = controller.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
//            .map { _ in ViewControllerEvent.appeared }
//
//        let didDisappearProducer = controller.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
//            .map { _ in ViewControllerEvent.disappeared }
//
//        Observable.of(didAppearProducer, didDisappearProducer)
//            .merge()
//            .bind(to: _viewControllerEvent)
//            .disposed(by: disposeBag)
//
//        return controller
//    }
//
//    open func updateBuildContext(_ buildContext: ModuleBuildContextProtocol) {
//        context = buildContext
//    }
//}
