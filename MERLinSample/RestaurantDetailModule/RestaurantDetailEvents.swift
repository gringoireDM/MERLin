//
//  RestaurantDetailEvents.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public enum RestaurantDetailEvent: EventProtocol {
    case bookButtonTapped(restaurant: RestaurantProtocol)
}
