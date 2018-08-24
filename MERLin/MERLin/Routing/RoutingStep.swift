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
    var make: () -> (Module, UIViewController) { get }
}

public protocol RoutingStep: ModuleMaking {
    associatedtype Route: Routable
}

///If the routing step happens to be the concrete context of the Module that is Routable
///then a default implementation of the make function is provided, using self as context
///for the Module concrete initializer.
extension RoutingStep where Route: Module, Route.Context == Self {
    public var make: () -> (Module, UIViewController)  {
        return {
            let module = Route(usingContext: self)
            return (module, module.buildRootViewController())
        }
    }
}

///A Module can be declared as routable. If so it can be built by a routingStep.
public protocol Routable {
    associatedtype Context: ModuleBuildContextProtocol
    
    init(usingContext buildContext: Context)
}
