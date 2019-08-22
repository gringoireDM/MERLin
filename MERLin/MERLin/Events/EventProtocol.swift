//
//  ModuleEvent.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import EnumKit
import Foundation

public typealias EventProtocol = CaseAccessible

public extension EventProtocol where Self == AnyEvent {
    func matches<T: EventProtocol>(event: T) -> Bool {
        guard let base = self.base as? T else { return false }
        return base ~= event
    }
    
    func matches<T: EventProtocol, Payload>(pattern: (Payload) -> T) -> Bool {
        guard let base = self.base as? T else { return false }
        return base ~= pattern
    }
    
    func extractPayload<T: EventProtocol, Payload>(ifMatches pattern: (Payload) -> T) -> Payload? {
        guard let base = self.base as? T else { return nil }
        return base[case: pattern]
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
