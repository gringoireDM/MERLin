//
//  EventsListening.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 08/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import RxSwift

public protocol AnyEventsListening: class {
    
    ///This method allows the event manager to register to a module's events.
    ///- parameter moduel: The module exposing the events
    ///- returns: Bool indicating if the module's events can be handled by the event manager
    @discardableResult func registerToEvents(for producer: AnyEventsProducer) -> Bool
}

public protocol EventsListening: AnyEventsListening {
    associatedtype EventsType: EventProtocol
    @discardableResult func registerToEvents(for producer: AnyEventsProducer, events: EventsProxy<EventsType>) -> Bool
}

public extension EventsListening {
    @discardableResult
    public func registerToEvents(for producer: AnyEventsProducer) -> Bool {
        guard let events = producer.eventsProxy(EventsType.self) else { return false }
        return registerToEvents(for: producer, events: events)
    }
}
