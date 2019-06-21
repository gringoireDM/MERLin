//
//  RxSwift+EventProtocol.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 29/08/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift

public extension ObservableType where Element == EventProtocol {
    @available(*, unavailable, renamed: "consume(eventType:)")
    func listen<T: EventProtocol>(to eventType: T.Type) -> Observable<T> {
        fatalError("renamed: use consume(eventType:) now")
    }
    
    func consume<T: EventProtocol>(eventType: T.Type) -> Observable<T> {
        return compactMap { $0 as? T }
    }
    
    func exclude<T: EventProtocol>(event target: T) -> Observable<T> {
        return consume(eventType: T.self)
            .exclude(event: target)
    }
    
    func capture<T: EventProtocol>(event target: T) -> Observable<T> {
        return consume(eventType: T.self)
            .capture(event: target)
    }
    
    func exclude<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<T> {
        return consume(eventType: T.self)
            .exclude(event: pattern)
    }
    
    func capture<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<Payload> {
        return consume(eventType: T.self)
            .capture(event: pattern)
    }
}

public extension ObservableType where Element: EventProtocol {
    func exclude(event target: Element) -> Observable<Element> {
        return filter { !$0.matches(event: target) }
    }
    
    func capture(event target: Element) -> Observable<Element> {
        return filter { $0.matches(event: target) }
    }
    
    func exclude<Payload>(event pattern: @escaping (Payload) -> Element) -> Observable<Element> {
        return filter { $0.extractPayload(ifMatches: pattern) == nil }
    }
    
    func capture<Payload>(event pattern: @escaping (Payload) -> Element) -> Observable<Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
    
    func toEventProtocol() -> Observable<EventProtocol> {
        return map { $0 as EventProtocol }
    }
    
    func toAnyEvent() -> Observable<AnyEvent> {
        return map(AnyEvent.init)
    }
}

public extension ObservableType where Element == AnyEvent {
    func capture<T: EventProtocol>(event target: T) -> Observable<T> {
        return filter { $0.matches(event: target) }
            .compactMap { $0.base as? T }
    }
    
    func capture<T: EventProtocol, Payload>(event pattern: @escaping (Payload) -> T) -> Observable<Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
}

public extension SharedSequenceConvertibleType where Element: EventProtocol {
    func capture(event target: Element) -> SharedSequence<SharingStrategy, Element> {
        return filter { $0.matches(event: target) }
    }
    
    func capture<Payload>(event pattern: @escaping (Payload) -> Element) -> SharedSequence<SharingStrategy, Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
}
