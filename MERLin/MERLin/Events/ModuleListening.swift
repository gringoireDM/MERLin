//
//  ModuleListening.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 09/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift

public protocol AnyModuleListening: AnyEventsListening {
    func handleEvents(for module: AnyEventsProducer & AnyModule) -> Bool
}

public extension AnyModuleListening {
    @discardableResult
    func registerToEvents(for producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducer & AnyModule else { return false }
        return handleEvents(for: producer)
    }
}

public protocol ModuleListening: AnyModuleListening {
    associatedtype EventsType: EventProtocol
    func handleEvents(for module: AnyEventsProducer & AnyModule, events: Observable<EventsType>) -> Bool
}

public extension ModuleListening {
    func registerToEvents(for producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducer & AnyModule else { return false }
        return handleEvents(for: producer)
    }
    
    func handleEvents(for module: AnyEventsProducer & AnyModule) -> Bool {
        guard let events = module.observable(of: EventsType.self) else { return false }
        return handleEvents(for: module, events: events)
    }
}

public protocol ModuleEventsListenerAggregator: AnyEventsListening {
    var moduleListeners: [AnyModuleListening] { get }
    var handledRoutingContext: [String] { get }
}

public extension ModuleEventsListenerAggregator {
    @discardableResult func registerToEvents(for producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducer & AnyModule,
            handledRoutingContext.contains(producer.routingContext) else { return false }
        
        return moduleListeners
            .reduce(false) { $0 || $1.handleEvents(for: producer) }
    }
}
