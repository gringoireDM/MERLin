//
//  SimpleRouter.swift
//  Restaurants
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import MERLin
import RxSwift

enum Themes {
    case defaultTheme, christmasTheme
    
    var theme: ThemeProtocol {
        switch self {
        case .defaultTheme: return Theme()
        case .christmasTheme: return ChristmasTheme()
        }
    }
    
    func next() -> Themes {
        guard case .defaultTheme = self else { return .defaultTheme }
        return .christmasTheme
    }
}

class SimpleRouter: Router {
    var viewControllersFactory: ViewControllersFactory?
    let disposeBag = DisposeBag()
    required init(withFactory factory: ViewControllersFactory) {
        viewControllersFactory = factory
    }
    
    var currentTheme: Themes = .defaultTheme {
        didSet {
            UIWindow.defaultTheme = currentTheme.theme
        }
    }
    
    var switchThemeButton: UIBarButtonItem {
        let button = UIBarButtonItem(title: "Switch Theme", style: .plain, target: nil, action: nil)
        button.rx.tap.subscribe(onNext: { [weak self] in
            guard let _self = self else { return }
            _self.currentTheme = _self.currentTheme.next()
        }).disposed(by: disposeBag)
        return button
    }
    
    var topViewController: UIViewController { return rootNavigationController }
    private lazy var rootNavigationController: UINavigationController =  {
        let presentableStep = PresentableRoutingStep(withStep: .restaurantsList(), presentationMode: .embed)
        let navController = UINavigationController(rootViewController: viewControllersFactory!.viewController(for: presentableStep))
        navController.rx.willShow
            .subscribe(onNext: { [weak self] (controller, animated) in
                controller.navigationItem.rightBarButtonItem = self?.switchThemeButton
        }).disposed(by: disposeBag)
        return navController
    }()
    
    func rootViewController(forLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> UIViewController? {
        return rootNavigationController
    }
    
    func handleShortcutItem(_ item: UIApplicationShortcutItem) {
        //Not implemented
    }
    
    func showLoadingView() {
        //Not implemented
    }
    
    func hideLoadingView() {
        //Not implemented
    }
}
