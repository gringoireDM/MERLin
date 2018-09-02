//
//  RestaurantDetailStep.swift
//  Restaurants
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RestaurantDetailModule

typealias InternalRestaurantDetailEvent = RestaurantDetailEvent

extension ModuleRoutingStep {
    static func restaurantsDetail(routingContext: RoutingContext = .mainFlow, restaurantId: String) -> ModuleRoutingStep {
        let step = RestaurantDetailBuildContext(withRoutingContext: routingContext.rawValue, restaurantId: restaurantId)
        return ModuleRoutingStep(withMaker: step)
    }
}
