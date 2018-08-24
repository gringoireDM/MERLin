//
//  EventsProducer.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

public protocol EventsProducer: class {
    var moduleName: String { get }
    var moduleSection: String { get }
    var moduleType: String { get }
    
    var disposeBag: DisposeBag { get }
    var reactive: EventsDescriptor { get }
}

public protocol RoutingEventsProducer: EventsProducer {
    var routingContext: String { get }
    var currentViewController: UIViewController? { get }
}
