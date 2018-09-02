//
//  RestaurantDetailModule.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

extension UIStoryboard {
    static var restaurant: UIStoryboard {
        return UIStoryboard(name: "Restaurant", bundle: Bundle(for: RestaurantDetailModule.self))
    }
}
public class RestaurantDetailModule: Module, RoutingEventsProducer, Routable {
    public var moduleName: String = "Restaurant Detail Page"
    public var moduleSection: String = "Restaurant Detail"
    public var moduleType: String = "Detail"
    public var eventsType: EventProtocol.Type = RestaurantDetailEvent.self
    
    public var events: Observable<EventProtocol> { return _events.toEventProtocol() }
    private var _events = PublishSubject<RestaurantDetailEvent>()

    var detailContext: RestaurantDetailBuildContext { return context as! RestaurantDetailBuildContext }
    
    open override var viewControllerFactory: ModuleViewControllerFactory? { return UIStoryboard.restaurant }

    open override var viewControllerTransform: ((UIViewController) -> Void)? {
        return { [weak self] viewController in
            guard let _self = self, let controller = viewController as? RestaurantDetailViewController else { return }
            controller.viewModel = RestaurantDetailViewModel(events: _self._events, restaurantId: _self.detailContext.id)
        }
    }
    
    public required init(usingContext buildContext: RestaurantDetailBuildContext) {
        super.init(withBuildContext: buildContext)
    }
}
