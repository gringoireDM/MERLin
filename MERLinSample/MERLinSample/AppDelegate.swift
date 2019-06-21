//
//  AppDelegate.swift
//  MERLinSample
//
//  Created by Giuseppe Lanza on 02/09/18.
//  Copyright © 2018 HBCDigital. All rights reserved.
//

import MERLin
import RxSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, EventsProducer {
    let moduleName: String = "app_launch"
    let moduleSection: String = "App launch"
    let moduleType: String = "App launch"
    
    let disposeBag = DisposeBag()
    
    var events: Observable<AppDelegateEvent> { return _events }
    private let _events = PublishSubject<AppDelegateEvent>()
    
    var window: UIWindow?
    
    var moduleManager: BaseModuleManager = BaseModuleManager()
    
    var router: SimpleRouter!
    lazy var eventsListeners: [AnyEventsConsumer] = {
        [
            ConsoleLogEventsListener(),
            AppDelegateEventsListener(withRouter: router),
            RoutingEventsListener(withRouter: router)
        ]
    }()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        router = SimpleRouter(withFactory: moduleManager)
        moduleManager.addEventsConsumers(eventsListeners)
        
        eventsListeners.forEach { $0.consumeEvents(from: self) }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = router.rootViewController(forLaunchOptions: launchOptions)
        window?.makeKeyAndVisible()
        
        _events.onNext(.didFinishLaunching)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard app.canOpenURL(url) == true else {
            return false
        }
        
        _events.onNext(.openURL(url: url))
        return true
    }
    
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        _events.onNext(.willContinueUserActivity(type: userActivityType))
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        _events.onNext(.continueUserActivity(userActivity))
        return true
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        _events.onNext(.failedToContinueUserActivity(type: userActivityType))
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        _events.onNext(.didUseShortcut(shortcutItem))
    }
}
