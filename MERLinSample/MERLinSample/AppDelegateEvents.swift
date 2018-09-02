//
//  AppDelegateEvents.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 27/07/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation
import MERLin

enum AppDelegateEvent: EventProtocol {
    case didFinishLaunching
    case openURL(url: URL)
    case willContinueUserActivity(type: String)
    case failedToContinueUserActivity(type: String)
    case continueUserActivity(NSUserActivity)
    case didUseShortcut(UIApplicationShortcutItem)
}
