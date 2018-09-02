//
//  AppDelegate.swift
//  MERLinSample
//
//  Created by Giuseppe Lanza on 02/09/18.
//  Copyright © 2018 HBCDigital. All rights reserved.
//

import UIKit
import MERLin
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, EventsProducer {
    let moduleName: String = "app_launch"
    let moduleSection: String = "App launch"
    let moduleType: String = "App launch"
    let eventsType: EventProtocol.Type = AppDelegateEvent.self
    
    let disposeBag = DisposeBag()
    
    var events: Observable<EventProtocol> { return _events.toEventProtocol() }
    private let _events = PublishSubject<AppDelegateEvent>()

    var window: UIWindow?

    var moduleManager: BaseModuleManager = BaseModuleManager()

    var router: SimpleRouter!
    lazy var eventsListeners: [EventsListening] = {
        return [
            ConsoleLogEventsListener(),
            AppDelegateEventsListener(withRouter: router),
            RoutingEventsListener(withRouter: router)
        ]
    }()

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        router = SimpleRouter(withFactory: moduleManager)
        moduleManager.addEventsListeners(eventsListeners)
        Module.defaultTheme = Theme()
        
        eventsListeners.forEach { $0.registerToEvents(for: self) }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.rootViewController = router.rootViewController(forLaunchOptions: launchOptions)
        window?.makeKeyAndVisible()
        
        _events.onNext(.didFinishLaunching)
        
        return true
    }

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
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

