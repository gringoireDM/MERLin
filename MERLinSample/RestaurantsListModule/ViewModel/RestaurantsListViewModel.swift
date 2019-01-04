//
//  RestaurantsListViewModel.swift
//  RestaurantsListModule
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

protocol RestaurantsListVMInput {
    var getFirstPage: Driver<Void> { get }
    var didSelect: Driver<ShortRestaurantProtocol> { get }
    var nextPage: Driver<Void> { get }
}

protocol RestaurantsListVMOutput {
    var newRestaurantsList: Driver<[ShortRestaurantProtocol]> { get }
    var newPage: Driver<[ShortRestaurantProtocol]> { get }
    var error: Driver<DisplayableError> { get }
}

protocol RestaurantsListViewModelProtocol {
    init(events: PublishSubject<RestaurantsListEvent>)
    func transform(input: RestaurantsListVMInput) -> RestaurantsListVMOutput
}

class RestaurantsListViewModel: RestaurantsListViewModelProtocol {
    struct Output: RestaurantsListVMOutput {
        let newRestaurantsList: Driver<[ShortRestaurantProtocol]>
        var newPage: Driver<[ShortRestaurantProtocol]>
        let error: Driver<DisplayableError>
    }
    
    let disposeBag = DisposeBag()
    private let repositories: [RestaurantsRepository] = [
        MockRepository() // This should simulate the fetch from the server
    ]
    
    private let events: PublishSubject<RestaurantsListEvent>
    
    required init(events: PublishSubject<RestaurantsListEvent>) {
        self.events = events
    }
    
    func transform(input: RestaurantsListVMInput) -> RestaurantsListVMOutput {
        input.didSelect
            .map(RestaurantsListEvent.restaurantCellTapped)
            .drive(events)
            .disposed(by: disposeBag)
        
        let errors = PublishSubject<DisplayableError>()
        let getFirstPage = repositories.getFirstPage()
        
        let newRestaurantsOutput = input.getFirstPage
            .flatMap({ _ in getFirstPage.asDriver(onErrorSendErrorTo: errors) })
        
        let getNextPage = repositories.getNextPage()
        
        let nextPage = input.nextPage
            .flatMap({ _ in
                getNextPage.asDriver(onErrorSendErrorTo: errors)
            })
        
        let output = Output(newRestaurantsList: newRestaurantsOutput, newPage: nextPage, error: errors.asDriverIgnoreError())
        return output
    }
}
