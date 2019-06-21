//
//  EventsConsumer.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 08/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift

@available(*, unavailable, renamed: "AnyEventsConsumer")
public protocol AnyEventsListening {}
@available(*, unavailable, renamed: "EventsConsumer")
public protocol EventsListening {}

public protocol AnyEventsConsumer: AnyObject {
    /// This method allows the event manager to register to a module's events.
    /// - parameter producer: The producer exposing the events
    /// - returns: Bool indicating if the module's events can be handled by the event manager
    @discardableResult
    func consumeEvents(from producer: AnyEventsProducer) -> Bool
}

public protocol EventsConsumer: AnyEventsConsumer {
    associatedtype EventsType: EventProtocol
    @discardableResult
    func consumeEvents(from producer: AnyEventsProducer, events: Observable<EventsType>) -> Bool
}

public extension EventsConsumer {
    @discardableResult
    func consumeEvents(from producer: AnyEventsProducer) -> Bool {
        guard let events = producer.observable(of: EventsType.self) else { return false }
        return consumeEvents(from: producer, events: events)
    }
}

public protocol EventsConsumersAggregator: AnyEventsConsumer {
    var consumers: [AnyEventsConsumer] { get }
}

public extension EventsConsumersAggregator {
    @discardableResult
    func consumeEvents(from producer: AnyEventsProducer) -> Bool {
        return consumers.reduce(false) { $0 || $1.consumeEvents(from: producer) }
    }
}
