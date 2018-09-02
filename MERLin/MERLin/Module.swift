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

open class Module: NSObject {
    public static var defaultRoutingContext: String = "default"
    public static var deeplinkRoutingContext: String = "deeplink"
    
    public static var defaultTheme: ModuleThemeProtocol! {
        didSet {
            defaultTheme.applyAppearance()
        }
    }
    
    public static var buildABTestingManager: () -> (manager: ABTesting?, stateMachine: ABTestingManagerStateMachine?) = { return (nil, nil) }
    
    public let disposeBag = DisposeBag()
    public var viewControllerEvent: Observable<ViewControllerEvent> { return _viewControllerEvent }
    private let _viewControllerEvent = BehaviorSubject<ViewControllerEvent>(value: .uninitialized)
    
    open private(set) var viewControllerFactory: ModuleViewControllerFactory?
    open private(set) var viewControllerTransform: ((UIViewController) -> Void)?
    
    public private(set) var context: ModuleBuildContextProtocol
    public var routingContext: String { return context.routingContext }
    
    public weak var currentViewController: UIViewController?
    
    public init(withBuildContext buildContext: ModuleBuildContextProtocol) {
        context = buildContext
        super.init()
    }
    
    open func buildRootViewController() -> UIViewController {
        let controller = currentViewController ?? viewControllerFactory?.instantiateInitialViewController() ?? UIViewController()
        currentViewController = controller
        viewControllerTransform?(controller)
        
        _viewControllerEvent.onNext(.initialized)
        
        let didAppearProducer = controller.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .map { _ in ViewControllerEvent.appeared }
        
        let didDisappearProducer = controller.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .map { _ in ViewControllerEvent.disappeared }
        
        Observable.of(didAppearProducer, didDisappearProducer)
            .merge()
            .bind(to: _viewControllerEvent)
            .disposed(by: disposeBag)
        
        return controller
    }
    
    open func updateBuildContext(_ buildContext: ModuleBuildContextProtocol) {
        context = buildContext
    }
}
