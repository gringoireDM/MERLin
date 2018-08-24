//
//  ModuleviewControllerFactory.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

public protocol ModuleViewControllerFactory {
    func instantiateInitialViewController() -> UIViewController?
    func instantiateViewController(withIdentifier identifier: String) -> UIViewController
}

extension UIStoryboard: ModuleViewControllerFactory { }
