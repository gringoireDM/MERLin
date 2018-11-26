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

public class RestaurantDetailModule: NSObject, ModuleProtocol, RoutingEventsProducer {
    public var context: RestaurantDetailBuildContext
    public weak var currentViewController: UIViewController?
    
    public var moduleName: String = "Restaurant Detail Page"
    public var moduleSection: String = "Restaurant Detail"
    public var moduleType: String = "Detail"
    
    public var events: Observable<RestaurantDetailEvent> { return _events }
    private var _events = PublishSubject<RestaurantDetailEvent>()
    
    public func unmanagedRootViewController() -> UIViewController {
        let controller = currentViewController ?? UIStoryboard.restaurant.instantiateInitialViewController()!
        guard let detailController = controller as? RestaurantDetailViewController else { return controller }
        detailController.viewModel = RestaurantDetailViewModel(events: _events, restaurantId: context.id)
        return detailController
    }
    
    public required init(usingContext buildContext: RestaurantDetailBuildContext) {
        context = buildContext
        super.init()
    }
}
