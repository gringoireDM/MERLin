//
//  Deeplink.swift
//  Module
//
//  Created by Giuseppe Lanza on 20/02/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public enum DeeplinkMatchingPriority: Int {
    case veryLow
    case low
    case medium
    case high
    case veryHigh
}

public protocol Deeplinkable: DeeplinkResponder {
    static var priority: DeeplinkMatchingPriority { get }
    
    /**
     This method will return a new deeplink composed by the first schema name defined
     in the concrete class, plus the unmatched part of the original deeplink.
     
     - parameter deeplink: The original deeplink you want the remainder of.
     - returns: A new deeplink for the unmatched part of the deeplink in parameter, or
     nil if there are no unmatched parameters in the deeplink.
     */
    static func remainderDeeplink(fromDeeplink deeplink: String) -> String?
    
    /// The class for the ViewController pointed by the deeplink. This can be used by the
    /// router for introspection on the current ViewControllers in the stack, to decide
    /// If a currently alive module must be updated, or if a new one must be created.
    static func classForDeeplinkingViewController() -> UIViewController.Type
    
    /// Instanciate a module and the viewController associated to a specified deeplink.
    static func module(fromDeeplink deeplink: String, userInfo: [String: Any]?) -> (AnyModule, UIViewController)?
    
    /// For living modules, this method will return the deeplink to recreate self
    /// with the same buildContext (if any).
    func deeplinkURL() -> URL?
}

public protocol DeeplinkContextUpdatable: Deeplinkable {
    /// This method will update the context of an existing module using a deeplink.
    /// If the module cannot handle the request for any reason the return value of this
    /// method will be false.
    @discardableResult func updateContext(for controller: UIViewController, fromDeeplink deeplink: String, userInfo: [String: Any]?) -> Bool
}

public extension Deeplinkable {
    static var priority: DeeplinkMatchingPriority { return .medium }
    
    static func remainderDeeplink(fromDeeplink deeplink: String) -> String? {
        return defaultRemainderDeeplink(fromDeeplink: deeplink)
    }
    
    static func defaultRemainderDeeplink(fromDeeplink deeplink: String) -> String? {
        guard let schema = deeplinkSchemaNames.first(where: { deeplink.hasPrefix($0) }),
            let match = deeplinkRegexes().compactMap({
                $0.firstMatch(in: deeplink,
                              range: NSRange(location: 0, length: deeplink.count))
            }).first,
            let range = Range(match.range(at: 0), in: deeplink) else { return nil }
        
        let remainder = String(deeplink.suffix(from: range.upperBound))
            .split(separator: "/")
            .filter { !$0.isEmpty }
            .map(String.init)
            .joined(separator: "/")
        
        guard remainder.count > 0, remainder != "/" else { return nil }
        
        let resultingDeeplink = "\(schema)://\(remainder)"
            .replacingOccurrences(of: "///", with: "//")
        return resultingDeeplink
    }
}

/// The responsibility of this entity are to store available deeplinkable modules in a key
/// value structure where the key is a regular expression able to match the deeplink that the
/// value (which is a class) can handle. This variable is fed in runtime, and it should never need
/// manual maintenance. To feed the matcher with a new module, just make it conformant with
/// Deeplinkable protocol and subclassing Module.
public extension DeeplinkMatcher {
    static var typedAvailableDeeplinkHandlers: [NSRegularExpression: DeeplinkResponder.Type] {
        return DeeplinkMatcher.availableDeeplinkHandlers()
            .reduce(into: [NSRegularExpression: DeeplinkResponder.Type]()) {
                guard let key = $1.key as? NSRegularExpression,
                    let value = $1.value as? DeeplinkResponder.Type else { return }
                $0[key] = value
            }
    }
}
