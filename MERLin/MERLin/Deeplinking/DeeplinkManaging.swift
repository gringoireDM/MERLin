//
//  DeeplinkManaging.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol DeeplinkManaging: AnyObject {
    func viewControllerType(fromDeeplink deeplink: String) -> UIViewController.Type?
    @discardableResult func update(viewController: UIViewController, fromDeeplink deeplink: String, userInfo: [String: Any]?) -> Bool
    func viewController(fromDeeplink deeplink: String, userInfo: [String: Any]?) -> UIViewController?
    func unmatchedDeeplinkRemainder(fromDeeplink deeplink: String) -> String?
    func canPush(viewController: UIViewController, forDeeplink deeplink: String) -> Bool
}
