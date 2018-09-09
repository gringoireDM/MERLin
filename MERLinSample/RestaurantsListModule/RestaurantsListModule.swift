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

public class RestaurantsListModule: NSObject, ModuleProtocol, RoutingEventsProducer {
    public weak var currentViewController: UIViewController?
    
    public var context: ModuleContext
    
    public var moduleName: String = "Restaurants List"
    public var moduleSection: String = "Restaurants List"
    public var moduleType: String = "List"
    public var eventsType: EventProtocol.Type = RestaurantsListEvent.self
    
    public var events: Observable<EventProtocol> { return _events.toEventProtocol() }
    private let _events = PublishSubject<RestaurantsListEvent>()
    
    public func unmanagedRootViewController() -> UIViewController {
        let controller = currentViewController ?? UIStoryboard.restaurantsList.instantiateInitialViewController()!
        guard let listController = controller as? RestaurantsListViewController else { return controller }
        listController.viewModel = RestaurantsListViewModel(events: _events)
        
        return listController
    }
    
    public required init(usingContext buildContext: ModuleContext) {
        context = buildContext
        super.init()
    }
}
