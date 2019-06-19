//
//  RoutingModuleListenerAggregator.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 09/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift

protocol AnyRoutingModuleListening {
    func handleEvents(for producer: AnyEventsProducer & AnyModule, events: Observable<AnyEvent>, router: Router)
}

protocol RoutingModuleListening: AnyRoutingModuleListening {
    associatedtype EventsType: EventProtocol
    func handleEvents(for producer: AnyEventsProducer & AnyModule, events: Observable<EventsType>, router: Router)
}

extension RoutingModuleListening {
    func handleEvents(for producer: AnyEventsProducer & AnyModule, events: Observable<AnyEvent>, router: Router) {
        guard let events = producer.observable(of: EventsType.self) else { return }
        handleEvents(for: producer, events: events, router: router)
    }
}

protocol RoutingModuleListenerAggregator: AnyEventsListening, Routing {
    var moduleListeners: [AnyRoutingModuleListening] { get }
    var handledRoutingContext: [String] { get }
}

extension RoutingModuleListenerAggregator {
    @discardableResult func registerToEvents(for producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducer & AnyModule,
            let events = producer.observable(of: AnyEvent.self),
            handledRoutingContext.contains(producer.routingContext) else { return false }
        
        moduleListeners
            .forEach { $0.handleEvents(for: producer, events: events, router: router) }
        
        return true
    }
}
