//
//  ModuleEvent.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

public protocol EventProtocol {}

public extension EventProtocol {
    var label: String {
        return Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }
    
    func matches(event: Self) -> Bool {
        let targetStr = event.label
        return label == targetStr
    }
    
    func matches<Payload>(pattern: (Payload) -> Self) -> Bool {
        return extractPayload(ifMatches: pattern) != nil
    }
    
    func extractPayload<Payload>() -> Payload? {
        return decompose()?.payload
    }
    
    func extractPayload<Payload>(ifMatches pattern: (Payload) -> Self) -> Payload? {
        guard let decomposed: (String, Payload) = decompose(),
            let patternLabel = Mirror(reflecting: pattern(decomposed.1)).children.first?.label,
            decomposed.0 == patternLabel else { return nil }
        
        return decomposed.1
    }
    
    private func decompose<Payload>() -> (label: String, payload: Payload)? {
        for case let (label?, value) in Mirror(reflecting: self).children {
            // At this point we must check if the value of the event is of the same type of Payload.
            // XCode 10 introduces single value tuples so that
            // `case event(String)` and `case event(name: String)` will have different types.
            // In the first case the value will be of type String, in the second will be of type
            // `(name: String)`. If value do not match payload we are looking for the second case
            // inspecting the Mirror of value.
            // multivalue Tuples will always succede in the first type case to `Payload`, so in the
            // second evaluation we are really just concerned about the single value tuples.
            if let result = (value as? Payload) ?? (Mirror(reflecting: value).children.first?.value as? Payload) {
                return (label, result)
            }
        }
        return nil
    }
}

public extension EventProtocol where Self == AnyEvent {
    func matches<T: EventProtocol>(event: T) -> Bool {
        guard let base = self.base as? T else { return false }
        return base.matches(event: event)
    }
    
    func matches<T: EventProtocol, Payload>(pattern: (Payload) -> T) -> Bool {
        guard let base = self.base as? T else { return false }
        return base.matches(pattern: pattern)
    }
    
    func extractPayload<T: EventProtocol, Payload>(ifMatches pattern: (Payload) -> T) -> Payload? {
        guard let base = self.base as? T else { return nil }
        return base.extractPayload(ifMatches: pattern)
    }
}

public struct AnyEvent: EventProtocol, CustomReflectable, CustomStringConvertible {
    var base: Any & EventProtocol
    init<H: EventProtocol>(base: H) {
        self.base = base
    }
    
    public var customMirror: Mirror {
        return Mirror(reflecting: base)
    }
    
    public var description: String {
        return String(describing: base)
    }
}
