//
//  Module.swift
//  Module
//
//  Created by Giuseppe Lanza on 05/02/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

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

        guard let producer = self as? EventsProducer,
            let viewControllerOnScreen = producer.reactive.viewControllerOnScreen else { return controller }
        
        let didAppearProducer = controller.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .map { _ in true }

        let didDisappearProducer = controller.rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .map { _ in false }

        Observable.of(didAppearProducer, didDisappearProducer)
            .merge()
            .bind(to: viewControllerOnScreen)
            .disposed(by: disposeBag)

        return controller
    }
    
    open func updateBuildContext(_ buildContext: ModuleBuildContextProtocol) {
        context = buildContext
    }
}
