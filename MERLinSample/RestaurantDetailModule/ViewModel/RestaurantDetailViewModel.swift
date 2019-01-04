//
//  RestaurantDetailVMProtocol.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

protocol RestaurantDetailVMInput {
    var viewWillAppear: Driver<Void> { get }
    var bookButtonTapped: Driver<RestaurantProtocol> { get }
}

protocol RestaurantDetailVMOutput {
    var restaurantDetailFetched: Driver<RestaurantProtocol> { get }
    var error: Driver<DisplayableError> { get }
}

protocol RestaurantDetailViewModelProtcol {
    init(events: PublishSubject<RestaurantDetailEvent>, restaurantId: String)
    func transform(input: RestaurantDetailVMInput) -> RestaurantDetailVMOutput
}

class RestaurantDetailViewModel: RestaurantDetailViewModelProtcol {
    struct Output: RestaurantDetailVMOutput {
        var restaurantDetailFetched: Driver<RestaurantProtocol>
        var error: Driver<DisplayableError>
    }
    
    let disposeBag = DisposeBag()
    private let repositories: [RestaurantRepository] = [
        MockRepository()
    ]
    
    private let events: PublishSubject<RestaurantDetailEvent>
    private let id: String
    required init(events: PublishSubject<RestaurantDetailEvent>, restaurantId: String) {
        self.events = events
        id = restaurantId
    }
    
    func transform(input: RestaurantDetailVMInput) -> RestaurantDetailVMOutput {
        input.bookButtonTapped
            .map(RestaurantDetailEvent.bookButtonTapped)
            .drive(events)
            .disposed(by: disposeBag)
        
        let errors = PublishSubject<DisplayableError>()
        
        let getDetail = repositories.getDetail(for: id)
        
        let restaurantDetailFetched = input.viewWillAppear.flatMap({ _ in getDetail.asDriver(onErrorSendErrorTo: errors) })
        
        return Output(restaurantDetailFetched: restaurantDetailFetched, error: errors.asDriverIgnoreError())
    }
}
