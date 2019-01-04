//
//  RxSwift+EventProtocol.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 29/08/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift

public extension ObservableType where E == EventProtocol {
    public func listen<T: EventProtocol>(to eventType: T.Type) -> Observable<T> {
        return compactMap { $0 as? T }
    }
    
    public func capture<T: EventProtocol>(event target: T) -> Observable<T> {
        return listen(to: T.self)
            .capture(event: target)
    }
    
    public func capture<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<Payload> {
        return listen(to: T.self)
            .capture(event: pattern)
    }
}

public extension ObservableType where E: EventProtocol {
    public func capture(event target: E) -> Observable<E> {
        return filter { $0.matches(event: target) }
    }
    
    public func capture<Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
    
    public func toEventProtocol() -> Observable<EventProtocol> {
        return map { $0 as EventProtocol }
    }
    
    public func toAnyEvent() -> Observable<AnyEvent> {
        return map(AnyEvent.init)
    }
}

public extension ObservableType where E == AnyEvent {
    public func capture<T: EventProtocol>(event target: T) -> Observable<T> {
        return filter { $0.matches(event: target) }
            .compactMap { $0.base as? T }
    }
    
    public func capture<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
}

public extension SharedSequenceConvertibleType where E: EventProtocol {
    public func capture(event target: E) -> SharedSequence<SharingStrategy, E> {
        return filter { $0.matches(event: target) }
    }
    
    public func capture<Payload>(event pattern: @escaping (Payload) -> E) -> SharedSequence<SharingStrategy, Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
}
