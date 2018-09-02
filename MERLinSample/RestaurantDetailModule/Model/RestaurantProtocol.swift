//
//  RestaurantProtocol.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol MenuItemProtocol {
    var title: String { get }
    var shortDescription: String { get }
    var price: Double { get }
    
    var longDescription: String { get }
}

public protocol MenuProtocol {
    var title: String { get }
    var items: [MenuItemProtocol] { get }
}

public protocol RestaurantProtocol {
    var id: String { get }
    var longitude: Double { get }
    var latitude: Double { get }
    var name: String { get }
    var priceRate: Double { get }
    var imageURLs: [URL] { get }
    var desc: String { get }
    var menus: [MenuProtocol] { get }
}

struct MenuItem: MenuItemProtocol {
    var title: String
    var shortDescription: String
    var price: Double
    
    var longDescription: String
}

struct Menu: MenuProtocol {
    var title: String
    var items: [MenuItemProtocol]
}

struct Restaurant: RestaurantProtocol, CustomStringConvertible {
    var id: String
    var longitude: Double
    var latitude: Double
    var name: String
    var priceRate: Double
    var imageURLs: [URL]
    var desc: String
    var menus: [MenuProtocol]
    
    var description: String {
        return name
    }
}
