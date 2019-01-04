//
//  RoutingStep.swift
//  PFRPG rd PRO
//
//  Created by Giuseppe Lanza on 07/06/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol ModuleMaking {
    var routingContext: String { get }
    var make: () -> (AnyModule, UIViewController) { get }
}

public protocol RoutingStep: ModuleMaking {
    associatedtype Route: ModuleProtocol
}

/// If the routing step happens to be the concrete context of the Module that is Routable
///then a default implementation of the make function is provided, using self as context
/// for the Module concrete initializer.
extension RoutingStep where Route.Context == Self {
    public var make: () -> (AnyModule, UIViewController) {
        return {
            let module = Route(usingContext: self)
            return (module, module.prepareRootViewController())
        }
    }
}
