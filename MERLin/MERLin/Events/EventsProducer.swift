//
//  EventsProducer.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public protocol AnyEventsProducer: class {
    var moduleName: String { get }
    var moduleSection: String { get }
    var moduleType: String { get }
    
    var disposeBag: DisposeBag { get }
    var anyEvents: Observable<EventProtocol> { get }
    
    func observable<E: EventProtocol>(of type: E.Type) -> Observable<E>?
}

public protocol EventsProducer: AnyEventsProducer {
    associatedtype EventsType: EventProtocol
    
    var events: Observable<EventsType> { get }
}

public extension AnyEventsProducer {
    public func capture<E: EventProtocol>(event target: E) -> Observable<E> {
        return anyEvents.capture(event: target)
    }
    
    public func capture<E: EventProtocol, Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return anyEvents.capture(event: pattern)
    }
    
    public subscript<E: EventProtocol>(event target: E) -> Observable<E> {
        return capture(event: target)
    }
    
    public subscript<E: EventProtocol, Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return capture(event: pattern)
    }
}

public extension EventsProducer {
    public var anyEvents: Observable<EventProtocol> { return events.toEventProtocol() }
    
    public func observable<E: EventProtocol>(of type: E.Type) -> Observable<E>? {
        // If E is AnyEvent, we want to transform the observable first. if the downcasting fails, then E is not AnyEvent.
        guard let e = events.toAnyEvent() as? Observable<E> ?? events as? Observable<E> else { return nil }
        return e
    }
}
