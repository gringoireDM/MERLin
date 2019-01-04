//
//  MockRepository.swift
//  RestaurantsListModule
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

extension String: Error {}

class MockRepository: RestaurantsRepository {
    func getNext() -> Single<[ShortRestaurantProtocol]> {
        return Single.create(subscribe: { [weak self] (single) -> Disposable in
            guard let _self = self else { single(.error("Uninitialized")); return Disposables.create() }
            let restaurants = _self.mockRestaurants(from: ListPageStateMachine.currentOffset, to: ListPageStateMachine.currentOffset + ListPageStateMachine.limit)
            single(.success(restaurants))
            return Disposables.create()
        }).do(onSuccess: { _ in
            ListPageStateMachine.currentOffset = ListPageStateMachine.currentOffset + ListPageStateMachine.limit
        })
    }
    
    func getRestaurants(limit: Int) -> Single<[ShortRestaurantProtocol]> {
        ListPageStateMachine.currentOffset = 0
        ListPageStateMachine.limit = limit
        return Single.create(subscribe: { [weak self] (single) -> Disposable in
            guard let _self = self else { single(.error("Uninitialized")); return Disposables.create() }
            let restaurants = _self.mockRestaurants(from: 0, to: limit)
            single(.success(restaurants))
            return Disposables.create()
        }).do(onSuccess: { _ in ListPageStateMachine.currentOffset = limit })
    }
    
    private func mockRestaurants(from: Int, to: Int) -> [ShortRestaurantProtocol] {
        return Array<Int>(from ..< to).map {
            ShortRestaurant(id: "\($0)", name: "Restaurant \($0)", priceRate: Double($0))
        }
    }
}
