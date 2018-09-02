//
//  RoutingEventsListener.swift
//  Restaurants
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import MERLin

class RoutingEventsListener: RouteEventsListening {
    let router: Router
    
    init(withRouter router: Router) {
        self.router = router
    }

    func registerToEvents(for producer: EventsProducer) -> Bool {
        producer[event: InternalRestaurantsListEvent.restaurantCellTapped]
            .map { $0.id }
            .subscribe(onNext: { [weak self] id in
                let step = ModuleRoutingStep.restaurantsDetail(restaurantId: id)
                let presentableStep = PresentableRoutingStep(withStep: step, presentationMode: .push(withCloseButton: false, onClose: nil))
                _ = self?.router.route(to: presentableStep)
            }).disposed(by: producer.disposeBag)
        
        return true
    }
}

