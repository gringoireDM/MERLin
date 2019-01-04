//
//  RestaurantsListStep.swift
//  Restaurants
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RestaurantsListModule

typealias InternalRestaurantsListEvent = RestaurantsListEvent

extension ModuleRoutingStep {
    static func restaurantsList(routingContext: RoutingContext = .mainFlow) -> ModuleRoutingStep {
        let step = ModuleContext(routingContext: routingContext.rawValue, building: RestaurantsListModule.self)
        return ModuleRoutingStep(withMaker: step)
    }
}
