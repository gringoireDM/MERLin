//
//  ModuleConsumer.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 09/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift

public typealias AnyEventsProducerModule = AnyEventsProducer & AnyModule

public protocol AnyModuleEventsConsumer: AnyEventsConsumer {
    func consumeEvents(from module: AnyEventsProducerModule) -> Bool
}

public extension AnyModuleEventsConsumer {
    @discardableResult
    func consumeEvents(from producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducerModule else { return false }
        return consumeEvents(from: producer)
    }
}

public protocol ModuleEventsConsumer: AnyModuleEventsConsumer {
    associatedtype EventsType: EventProtocol
    func consumeEvents(from module: AnyEventsProducerModule, events: Observable<EventsType>) -> Bool
}

public extension ModuleEventsConsumer {
    func consumeEvents(from producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducerModule else { return false }
        return consumeEvents(from: producer)
    }
    
    func consumeEvents(from module: AnyEventsProducerModule) -> Bool {
        guard let events = module.observable(of: EventsType.self) else { return false }
        return consumeEvents(from: module, events: events)
    }
}

public protocol ModuleEventsConsumersAggregator: AnyEventsConsumer {
    /// the consumers aggregated by this Aggregator
    var moduleConsumers: [AnyModuleEventsConsumer] { get }
    
    /// Use this variable to restrict the routing context the aggregator can handle.
    /// set it to nil to not restrict to specific routing contexts.
    var handledRoutingContext: [String]? { get }
}

public extension ModuleEventsConsumersAggregator {
    @discardableResult func consumeEvents(from producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducerModule,
            handledRoutingContext == nil || handledRoutingContext!.contains(producer.routingContext) else { return false }
        
        return moduleConsumers
            .reduce(false) { $0 || $1.consumeEvents(from: producer) }
    }
}
