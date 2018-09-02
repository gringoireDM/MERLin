//
//  ShortRestaurantProtocol.swift
//  RestaurantsListModule
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol ShortRestaurantProtocol: Codable {
    var id: String { get }
    var name: String { get }
    var priceRate: Double { get }
}

internal struct ShortRestaurant: Codable, ShortRestaurantProtocol {
    let id: String
    let name: String
    let priceRate: Double
}
