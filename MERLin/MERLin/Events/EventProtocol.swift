//
//  ModuleEvent.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

public protocol EventProtocol { }

public extension EventProtocol {
    public func matches(event: Self) -> Bool {
        let targetStr = Mirror(reflecting: event).children.first?.label ?? String(describing: event)
        let thisStr = Mirror(reflecting: self).children.first?.label ?? String(describing: self)
        return thisStr == targetStr
    }
    
    public func matches<Payload>(pattern: (Payload) -> Self) -> Bool {
        return extractPayload(ifMatches: pattern) != nil
    }
    
    public func extractPayload<Payload>() -> Payload? {
        return decompose()?.payload
    }
    
    public func extractPayload<Payload>(ifMatches pattern: (Payload)->Self) -> Payload? {
        guard let decomposed: (String, Payload) = decompose(),
            let patternLabel = Mirror(reflecting: pattern(decomposed.1)).children.first?.label,
            decomposed.0 == patternLabel else { return nil }
        
        return decomposed.1
    }
    
    public func decompose<Payload>() -> (label: String, payload: Payload)? {
        for case let (label?, value) in Mirror(reflecting: self).children {
            //At this point we must check if the value of the event is of the same type of Payload.
            //XCode 10 introduces single value tuples so that
            //`case event(String)` and `case event(name: String)` will have different types.
            //In the first case the value will be of type String, in the second will be of type
            //`(name: String)`. If value do not match payload we are looking for the second case
            //inspecting the Mirror of value.
            //multivalue Tuples will always succede in the first type case to `Payload`, so in the
            //second evaluation we are really just concerned about the single value tuples.
            if let result = (value as? Payload) ?? (Mirror(reflecting: value).children.first?.value as? Payload) {
                return (label, result)
            }
        }
        return nil
    }
}
