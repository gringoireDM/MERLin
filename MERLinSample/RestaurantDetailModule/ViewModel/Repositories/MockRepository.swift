//
//  MockRestaurantRepository.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

extension Menu {
    static func mockMenus() -> [Menu] {
        let menuItems = [
            MenuItem(title: "Carbonara", shortDescription: "Fresh pasta, eggs, pecorino cheese and bacon", price: 9, longDescription: "Spaghetti cooked aldente, with crunchy bacon and delicious egg and pecorino cheese sauce"),
            MenuItem(title: "Spaghetti alla bolognese", shortDescription: "Spaghetti, minced beef, red bolognese sauce", price: 12, longDescription: "Spaghetti cooked aldente, with first selection of minced beef cooked in red sauce with carrots, onions and other ingredients i don't remember"),
            MenuItem(title: "Tonno e olive", shortDescription: "Maccheroni, tunna and olives", price: 12, longDescription: "Maccheroni cooked al dente with black olives, green olives and tunna"),
            MenuItem(title: "Farfalle al salmone", shortDescription: "Pasta, salmon, panna", price: 12, longDescription: "Laces with salmon sauce made with salmon and panna. Perfect with white wine")
        ]
        
        let pastaMenu = Menu(title: "Pasta", items: menuItems)
        
        let pizzaMenuItems = [
            MenuItem(title: "Margherita", shortDescription: "Mozzarella, red Sauce", price: 13, longDescription: "Pizza with fresh mozzarella, red sauce with pomodorini di san marzano and basil"),
            MenuItem(title: "Bufalina", shortDescription: "Buffalo mozzarella from battipaglia, red Sauce", price: 13, longDescription: "Pizza with fresh buffalo mozzarella from Battipaglia, red sauce with pomodorini di san marzano and basil"),
            MenuItem(title: "Marinara", shortDescription: "Red sauce and oregano", price: 12, longDescription: "Simple pizza with no mozzarella, red sauce and oregano"),
            MenuItem(title: "Prosciutto e funghi", shortDescription: "Mozzarella, parma ham and mushrooms", price: 12, longDescription: "White pizza with mozzarella, parma ham and mushrooms")
        ]
        
        let pizzaMenu = Menu(title: "Pizza", items: pizzaMenuItems)
        
        return [pastaMenu, pizzaMenu]
    }
}

struct MockRepository: RestaurantRepository {
    func getRestaurantDetail(for id: String) -> Single<RestaurantProtocol> {
        return Single.create(subscribe: { (single) -> Disposable in
            let restaurant = Restaurant(id: id, longitude: 0, latitude: 0, name: "Restaurant \(id)", priceRate: Double(id)!, imageURLs: [], desc: "Ristorante/Pizzeria", menus: Menu.mockMenus())
            single(.success(restaurant))
            return Disposables.create()
        })
    }
}
