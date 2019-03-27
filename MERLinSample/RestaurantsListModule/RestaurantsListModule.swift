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

public class RestaurantsListModule: NSObject, ModuleProtocol, EventsProducer, PageRepresenting {
    public var context: ModuleContext
    
    public var pageName: String = "Restaurants List"
    public var section: String = "Restaurants List"
    public var pageType: String = "List"
    
    public var events: Observable<RestaurantsListEvent> { return _events }
    private let _events = PublishSubject<RestaurantsListEvent>()
    
    public func unmanagedRootViewController() -> UIViewController {
        let controller = UIStoryboard.restaurantsList.instantiateInitialViewController()!
        guard let listController = controller as? RestaurantsListViewController else { return controller }
        listController.viewModel = RestaurantsListViewModel(events: _events)
        
        return listController
    }
    
    public required init(usingContext buildContext: ModuleContext) {
        context = buildContext
        super.init()
    }
}
