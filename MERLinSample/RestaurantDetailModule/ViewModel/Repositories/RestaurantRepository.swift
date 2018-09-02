//
//  RestaurantRepository.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

protocol RestaurantRepository {
    func getRestaurantDetail(for id: String) -> Single<RestaurantProtocol>
}


extension Array where Element == RestaurantRepository {
    func getDetail(for id: String) -> Single<RestaurantProtocol> {
        var getRestaurant: Single<RestaurantProtocol>!
        for repo in self {
            if getRestaurant == nil {
                getRestaurant = repo.getRestaurantDetail(for: id)
            } else {
                getRestaurant = getRestaurant.catchError { _ in
                    //could check if the error is a connectivity error and have a better error handling
                    return repo.getRestaurantDetail(for: id)
                }
            }
        }
        return getRestaurant
    }
}
