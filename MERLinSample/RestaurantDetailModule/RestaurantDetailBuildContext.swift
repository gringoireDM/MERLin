//
//  RestaurantDetailBuildContext.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public struct RestaurantDetailBuildContext: ModuleBuildContextProtocol, RoutingStep {
    public typealias Route = RestaurantDetailModule
    
    public var routingContext: String
    public var id: String
    
    public init(withRoutingContext routingContext: String, restaurantId: String) {
        self.routingContext = routingContext
        id = restaurantId
    }
}
