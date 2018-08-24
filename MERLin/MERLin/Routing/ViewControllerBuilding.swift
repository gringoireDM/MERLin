//
//  ViewControllerFactory.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol ViewControllerBuilding: class {
    func viewController(for routingStep: PresentableRoutingStep) -> UIViewController
}
