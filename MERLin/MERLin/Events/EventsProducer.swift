//
//  EventsProducer.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import RxSwift

public protocol EventsProducer: class {
    var moduleName: String { get }
    var moduleSection: String { get }
    var moduleType: String { get }
    
    var eventsType: EventProtocol.Type { get }
    
    var disposeBag: DisposeBag { get }
    var events: Observable<EventProtocol> { get }
}

public protocol RoutingEventsProducer: EventsProducer {
    var viewControllerEvent: Observable<ViewControllerEvent> { get }
    
    var routingContext: String { get }
    var currentViewController: UIViewController? { get }
}

public extension EventsProducer {
    public func capture<E: EventProtocol>(event target: E) -> Observable<E> {
        return events.capture(event: target)
    }
    
    public func capture<E: EventProtocol, Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return events.capture(event: pattern)
    }
    
    public subscript<E: EventProtocol>(event target: E) -> Observable<E> {
        return capture(event: target)
    }
    
    public subscript<E: EventProtocol, Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return capture(event: pattern)
    }
}
