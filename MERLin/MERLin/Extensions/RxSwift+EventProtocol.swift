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
    func listen<T: EventProtocol>(to eventType: T.Type) -> Observable<T> {
        return compactMap { $0 as? T }
    }
    
    func exclude<T: EventProtocol>(event target: T) -> Observable<T> {
        return listen(to: T.self)
            .exclude(event: target)
    }
    
    func capture<T: EventProtocol>(event target: T) -> Observable<T> {
        return listen(to: T.self)
            .capture(event: target)
    }
    
    func exclude<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<T> {
        return listen(to: T.self)
            .exclude(event: pattern)
    }
    
    func capture<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<Payload> {
        return listen(to: T.self)
            .capture(event: pattern)
    }
}

public extension ObservableType where E: EventProtocol {
    func exclude(event target: E) -> Observable<E> {
        return filter { !$0.matches(event: target) }
    }
    
    func capture(event target: E) -> Observable<E> {
        return filter { $0.matches(event: target) }
    }
    
    func exclude<Payload>(event pattern: @escaping (Payload) -> E) -> Observable<E> {
        return filter { $0.extractPayload(ifMatches: pattern) == nil }
    }
    
    func capture<Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
    
    func toEventProtocol() -> Observable<EventProtocol> {
        return map { $0 as EventProtocol }
    }
    
    func toAnyEvent() -> Observable<AnyEvent> {
        return map(AnyEvent.init)
    }
}

public extension ObservableType where E == AnyEvent {
    func capture<T: EventProtocol>(event target: T) -> Observable<T> {
        return filter { $0.matches(event: target) }
            .compactMap { $0.base as? T }
    }
    
    func capture<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
}

public extension SharedSequenceConvertibleType where E: EventProtocol {
    func capture(event target: E) -> SharedSequence<SharingStrategy, E> {
        return filter { $0.matches(event: target) }
    }
    
    func capture<Payload>(event pattern: @escaping (Payload) -> E) -> SharedSequence<SharingStrategy, Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
}
