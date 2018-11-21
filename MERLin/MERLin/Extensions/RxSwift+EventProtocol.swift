//
//  RxSwift+EventProtocol.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 29/08/18.

//

import RxSwift
import RxCocoa

public extension ObservableType where E == EventProtocol {
    public func listen<T: EventProtocol>(to eventType: T.Type) -> Observable<T> {
        return map { $0 as? T }
            .unwrap()
    }
    
    public func capture<T: EventProtocol>(event target: T) -> Observable<T> {
        return listen(to: T.self)
            .capture(event: target)
    }
    
    public func capture<T: EventProtocol, Payload>(event pattern: @escaping (Payload)->T) -> Observable<Payload> {
        return listen(to: T.self)
            .capture(event: pattern)
    }
}

public extension ObservableType where E: EventProtocol {
    public func capture(event target: E) -> Observable<E> {
        return filter { $0.matches(event: target) }
    }

    public func capture<Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return map { $0.extractPayload(ifMatches: pattern) }
            .unwrap()
    }
    
    public func toEventProtocol() -> Observable<EventProtocol> {
        return self.map { $0 as EventProtocol }
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E: EventProtocol {
    public func capture(event target: E) -> Driver<E> {
        return filter { $0.matches(event: target) }
    }

    public func capture<Payload>(event pattern: @escaping (Payload) -> E) -> Driver<Payload> {
        return map { $0.extractPayload(ifMatches: pattern) }
            .unwrap()
    }
    
}
