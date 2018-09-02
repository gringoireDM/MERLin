//
//  RestaurantsListModule.swift
//  RestaurantsListModule
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public enum RestaurantsListEvent: EventProtocol {
    case restaurantCellTapped(restaurant: ShortRestaurantProtocol)
}

extension UIStoryboard {
    static var restaurantsList: UIStoryboard {
        return UIStoryboard(name: "RestaurantsList", bundle: Bundle(for: RestaurantsListModule.self))
    }
}

public class RestaurantsListModule: Module, RoutingEventsProducer, Routable {
    public var moduleName: String = "Restaurants List"
    public var moduleSection: String = "Restaurants List"
    public var moduleType: String = "List"
    public var eventsType: EventProtocol.Type = RestaurantsListEvent.self
    
    public var events: Observable<EventProtocol> { return _events.toEventProtocol() }
    private let _events = PublishSubject<RestaurantsListEvent>()
    
    open override var viewControllerFactory: ModuleViewControllerFactory? { return UIStoryboard.restaurantsList }
    open override var viewControllerTransform: ((UIViewController) -> Void)? {
        return { [weak self] viewController in
            guard let _self = self, let controller = viewController as? RestaurantsListViewController else { return }
            controller.viewModel = RestaurantsListViewModel(events: _self._events)
        }
    }
    
    public required init(usingContext buildContext: ModuleContext) {
        super.init(withBuildContext: buildContext)
    }
}
