//
//  ModuleListener.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 09/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift

public typealias AnyEventsProducerModule = AnyEventsProducer & AnyModule

public protocol AnyModuleEventsListener: AnyEventsListener {
    @discardableResult
    func listenEvents(from module: AnyEventsProducerModule) -> Bool
}

public extension AnyModuleEventsListener {
    @discardableResult
    func listenEvents(from producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducerModule else { return false }
        return listenEvents(from: producer)
    }
}

public protocol ModuleEventsListener: AnyModuleEventsListener {
    associatedtype EventsType: EventProtocol
    @discardableResult
    func listenEvents(from module: AnyEventsProducerModule, events: Observable<EventsType>) -> Bool
}

public extension ModuleEventsListener {
    @discardableResult
    func listenEvents(from producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducerModule else { return false }
        return listenEvents(from: producer)
    }
    
    @discardableResult
    func listenEvents(from module: AnyEventsProducerModule) -> Bool {
        guard let events = module.observable(of: EventsType.self) else { return false }
        return listenEvents(from: module, events: events)
    }
}

public protocol ModuleEventsListenersAggregator: AnyEventsListener {
    /// the listeners aggregated by this Aggregator
    var moduleListeners: [AnyModuleEventsListener] { get }
    
    /// Use this variable to restrict the routing context the aggregator can handle.
    /// set it to nil to not restrict to specific routing contexts.
    var handledRoutingContext: [String]? { get }
}

public extension ModuleEventsListenersAggregator {
    @discardableResult
    func listenEvents(from producer: AnyEventsProducer) -> Bool {
        guard let producer = producer as? AnyEventsProducerModule,
            handledRoutingContext == nil || handledRoutingContext!.contains(producer.routingContext) else { return false }
        
        return moduleListeners
            .map { $0.listenEvents(from: producer) }
            .reduce(false) { $0 || $1 }
    }
}
