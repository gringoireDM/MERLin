//
//  RoutingStep.swift
//  RestaurantsListModule
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public struct RestaurantsListStep: RoutingStep {
    public typealias Route = RestaurantsListModule
    
    public let routingContext: String
    
    public var make: () -> (Module, UIViewController)  {
        return {
            let context = ModuleContext(routingContext: self.routingContext)
            let module = RestaurantsListModule(usingContext: context)
            return (module, module.buildRootViewController())
        }
    }
    
    public init(routingContext: String) {
        self.routingContext = routingContext
    }
}
