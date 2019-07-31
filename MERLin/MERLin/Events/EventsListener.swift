//
//  EventsListener.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 08/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift

public protocol AnyEventsListener: AnyObject {
    /// This method allows the event manager to subscribe to a module's events.
    /// - parameter producer: The producer exposing the events
    /// - returns: Bool indicating if the module's events can be handled by the event manager
    @discardableResult
    func listenEvents(from producer: AnyEventsProducer) -> Bool
}

public protocol EventsListener: AnyEventsListener {
    associatedtype EventsType: EventProtocol
    @discardableResult
    func listenEvents(from producer: AnyEventsProducer, events: Observable<EventsType>) -> Bool
}

public extension EventsListener {
    @discardableResult
    func listenEvents(from producer: AnyEventsProducer) -> Bool {
        guard let events = producer.observable(of: EventsType.self) else { return false }
        return listenEvents(from: producer, events: events)
    }
}

public protocol EventsListenersAggregator: AnyEventsListener {
    var listeners: [AnyEventsListener] { get }
}

public extension EventsListenersAggregator {
    @discardableResult
    func listenEvents(from producer: AnyEventsProducer) -> Bool {
        return listeners.reduce(false) { $0 || $1.listenEvents(from: producer) }
    }
}
