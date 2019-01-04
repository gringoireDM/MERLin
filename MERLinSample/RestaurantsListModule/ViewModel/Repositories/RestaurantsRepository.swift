//
//  RestaurantsRepository.swift
//  RestaurantsListModule
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

protocol RestaurantsRepository {
    func getNext() -> Single<[ShortRestaurantProtocol]>
    func getRestaurants(limit: Int) -> Single<[ShortRestaurantProtocol]>
}

// This extension is meant to combine the getter from repositories with fallbacks.
// The preferences are in FIFO order and on error the next repository acts as fallback.
// if ultimately all the repositories cannot handle the request the error is propagated
//to the listeners.
extension Array where Element == RestaurantsRepository {
    func getFirstPage() -> Single<[ShortRestaurantProtocol]> {
        var getRestaurants: Single<[ShortRestaurantProtocol]>!
        for repo in self {
            if getRestaurants == nil {
                getRestaurants = repo.getRestaurants(limit: 20)
            } else {
                getRestaurants = getRestaurants.catchError { _ in
                    // could check if the error is a connectivity error and have a better error handling
                    repo.getRestaurants(limit: 20)
                }
            }
        }
        return getRestaurants
    }
    
    func getNextPage() -> Single<[ShortRestaurantProtocol]> {
        var getRestaurants: Single<[ShortRestaurantProtocol]>!
        for repo in self {
            if getRestaurants == nil {
                getRestaurants = repo.getNext()
            } else {
                getRestaurants = getRestaurants.catchError { _ in
                    // could check if the error is a connectivity error and have a better error handling
                    repo.getNext()
                }
            }
        }
        return getRestaurants
    }
}
