//
//  SimpleRouter.swift
//  Restaurants
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import MERLin
import RxSwift

class SimpleRouter: Router {
    var viewControllersFactory: ViewControllersFactory?
    
    required init(withFactory factory: ViewControllersFactory) {
        viewControllersFactory = factory
    }
    
    var topViewController: UIViewController { return rootNavigationController }
    private lazy var rootNavigationController: UINavigationController =  {
        let presentableStep = PresentableRoutingStep(withStep: .restaurantsList(), presentationMode: .embed)
        return UINavigationController(rootViewController: viewControllersFactory!.viewController(for: presentableStep))
    }()
    
    let disposeBag: DisposeBag = DisposeBag()
    
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
