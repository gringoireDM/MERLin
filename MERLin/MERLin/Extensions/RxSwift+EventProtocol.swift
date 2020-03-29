//
//  RxSwift+EventProtocol.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 29/08/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public extension ObservableType where Element: EventProtocol {
    func toEventProtocol() -> Observable<EventProtocol> {
        return map { $0 as EventProtocol }
    }
    
    func toAnyEvent() -> Observable<AnyEvent> {
        return map(AnyEvent.init)
    }
}

public extension ObservableType where Element == AnyEvent {
    func capture<T: EventProtocol>(case target: T) -> Observable<T> {
        return filter { $0.matches(event: target) }
            .compactMap { $0.base as? T }
    }
    
    func capture<T: EventProtocol, Payload>(case pattern: @escaping (Payload) -> T) -> Observable<Payload> {
        return compactMap { $0.extractPayload(ifMatches: pattern) }
    }
}
