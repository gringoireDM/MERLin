//
//  RxSwift+EventProtocol.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 29/08/18.
//  Copyright © 2018 Gilt. All rights reserved.
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

fileprivate func _capture<E: EventProtocol>(target: E, this: E) -> Bool {
    let targetStr = Mirror(reflecting: target).children.first?.label ?? String(describing: target)
    let thisStr = Mirror(reflecting: this).children.first?.label ?? String(describing: this)
    return thisStr == targetStr
}

fileprivate func _capture<E: EventProtocol, Payload>(pattern: @escaping (Payload) -> E, this: E) -> Payload? {
    for case let (label?, value) in Mirror(reflecting: this).children {
        //At this point we must check if the value of the event is of the same type of Payload.
        //XCode 10 introduces single value tuples so that
        //`case event(String)` and `case event(name: String)` will have different types.
        //In the first case the value will be of type String, in the second will be of type
        //`(name: String)`. If value do not match payload we are looking for the second case
        //inspecting the Mirror of value.
        //multivalue Tuples will always succede in the first type case to `Payload`, so in the
        //second evaluation we are really just concerned about the single value tuples.
        if let result = (value as? Payload) ?? (Mirror(reflecting: value).children.first?.value as? Payload),
            let patternLabel = Mirror(reflecting: pattern(result)).children.first?.label,
            label == patternLabel {
            return result
        }
    }
    return nil
}

public extension ObservableType where E: EventProtocol {
    public func capture(event target: E) -> Observable<E> {
        return filter { _capture(target: target, this: $0) }
    }

    public func capture<Payload>(event pattern: @escaping (Payload) -> E) -> Observable<Payload> {
        return map { _capture(pattern: pattern, this: $0) }
            .unwrap()
    }
    
    public func toEventProtocol() -> Observable<EventProtocol> {
        return self.map { $0 as EventProtocol }
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E: EventProtocol {
    public func capture(event target: E) -> Driver<E> {
        return filter { _capture(target: target, this: $0) }
    }

    public func capture<Payload>(event pattern: @escaping (Payload) -> E) -> Driver<Payload> {
        return map { _capture(pattern: pattern, this: $0) }
            .unwrap()
    }
    
}
