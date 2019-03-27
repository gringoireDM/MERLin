//
//  EventsProducer.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public protocol AnyEventsProducer: class {
    var disposeBag: DisposeBag { get }
    var anyEvents: Observable<EventProtocol> { get }
    
    func observable<E: EventProtocol>(of type: E.Type) -> Observable<E>?
}

public protocol EventsProducer: AnyEventsProducer {
    associatedtype EventsType: EventProtocol
    
    var events: Observable<EventsType> { get }
}

public extension AnyEventsProducer {
    func capture<E: EventProtocol>(event target: E) -> Observable<E> {
        return anyEvents.capture(event: target)
    }
    
    func capture<E: EventProtocol, Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return anyEvents.capture(event: pattern)
    }
    
    subscript<E: EventProtocol>(event target: E) -> Observable<E> {
        return capture(event: target)
    }
    
    subscript<E: EventProtocol, Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return capture(event: pattern)
    }
}

public extension EventsProducer {
    var anyEvents: Observable<EventProtocol> { return events.toEventProtocol() }
    
    func observable<E: EventProtocol>(of type: E.Type) -> Observable<E>? {
        // If E is AnyEvent, we want to transform the observable first. if the downcasting fails, then E is not AnyEvent.
        guard let e = events.toAnyEvent() as? Observable<E> ?? events as? Observable<E> else { return nil }
        return e
    }
}
