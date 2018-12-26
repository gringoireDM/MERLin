//
//  MockRouter.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 26/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift
import MERLin

class MockRouter: Router {
    var window: UIWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    var viewControllersFactory: ViewControllersFactory?
    
    var topViewController: UIViewController {
        didSet {
            window.subviews.forEach { $0.removeFromSuperview() }
            setCurrentToWindow()
        }
    }
    
    var disposeBag: DisposeBag = DisposeBag()

    init(withRootViewController root: UIViewController) {
        topViewController = root
        setCurrentToWindow()
    }
    
    func setCurrentToWindow() {
        window.rootViewController = topViewController
        topViewController.view.frame = window.bounds
        window.addSubview(topViewController.view)
    }
    
    func rootViewController(forLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> UIViewController? {
        return topViewController
    }
    
    func handleShortcutItem(_ item: UIApplicationShortcutItem) { }
    func showLoadingView() { }
    func hideLoadingView() { }
}
