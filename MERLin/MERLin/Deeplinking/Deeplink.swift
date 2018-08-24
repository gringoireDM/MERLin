//
//  Deeplink.swift
//  Module
//
//  Created by Giuseppe Lanza on 20/02/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

/**
 Make a Module subclass conforming this protocol to make that module
 automatically deeplinkable. The principle behind this automatic implementation
 is that to make a module deeplinkable should be simple enough and should not
 require additional code, and the list of available deeplinkable modules should
 reflect (and expand) accordingly to the modules built in the app.
 The removal or the addition of a Deeplinkable module **must** not affect the
 rest of the app. The list of available deeplinkable modules is built in runtime
 so that no maintenance is needed once the deeplink engin is built to be agnostic
 respect the modules that are going to be deeplinked. In this way, also god
 deeplink managers are avoided, and nobody knows how to build a module out of a
 deeplink, if not the module itself.
 */
@objc public protocol DeeplinkResponder: NSObjectProtocol {
    ///The schemas that can be used for the deeplink. They will be used in the regex
    ///chained as **or** matches. `(schema1|schema2):\/\/....`
    static var deeplinkSchemaNames: [String] { get set }

    ///The regex to parse the deeplink and decide if the module implementing Deeplinkable
    ///can handle the deeplink.
    @objc static func deeplinkRegexes() -> [NSRegularExpression]?
}

public protocol Deeplinkable: DeeplinkResponder {
    ///The class for the ViewController pointed by the deeplink. This can be used by the
    ///router for introspection on the current ViewControllers in the stack, to decide
    ///If a currently alive module must be updated, or if a new one must be created.
    static func classForDeeplinkingViewController() -> UIViewController.Type
    
    ///Instanciate a module and the viewController associated to a specified deeplink.
    static func module(fromDeeplink deeplink: String) -> (Module, UIViewController)?

    ///For living modules, this method will return the deeplink to recreate self
    ///with the same buildContext (if any).
    func deeplinkURL() -> URL?
}

public protocol DeeplinkContextUpdatable: Deeplinkable {
    ///This method will update the context of an existing module using a deeplink.
    ///If the module cannot handle the request for any reason the return value of this
    ///method will be false.
    @discardableResult func updateContext(fromDeeplink deeplink: String) -> Bool
}

public extension Deeplinkable {
    /**
     This method will return a new deeplink composed by the first schema name defined
     in the concrete class, plus the unmatched part of the original deeplink.
     
     - parameter deeplink: The original deeplink you want the remainder of.
     - returns: A new deeplink for the unmatched part of the deeplink in parameter, or
     nil if there are no unmatched parameters in the deeplink.
     */
    static public func remainderDeeplink(fromDeeplink deeplink: String) -> String? {
        guard let schema = deeplinkSchemaNames.first,
            let match = deeplinkRegexes()?.compactMap({ $0.firstMatch(in: deeplink, range: NSRange(location: 0, length: deeplink.count)) }).first,
            let range = Range(match.range(at: 0), in: deeplink) else { return nil }
        
        let remainder = String(deeplink.suffix(from: range.upperBound))
        guard remainder.count > 0 && remainder != "/" else { return nil }
        
        let resultingDeeplink = "\(schema)://\(remainder)".replacingOccurrences(of: "///", with: "//")
        return resultingDeeplink
    }
}

///The responsibility of this entity are to store available deeplinkable modules in a key
///value structure where the key is a regular expression able to match the deeplink that the
///value (which is a class) can handle. This variable is fed in runtime, and it should never need
///manual maintenance. To feed the matcher with a new module, just make it conformant with
///Deeplinkable protocol and subclassing Module.
@objc public class DeeplinkMatcher: NSObject {
    @objc static public internal(set) var availableDeeplinkHandlers: NSMutableDictionary = [:]
    static public var typedAvailableDeeplinkHandlers: [NSRegularExpression: DeeplinkResponder.Type] {
        return availableDeeplinkHandlers.reduce([NSRegularExpression: DeeplinkResponder.Type]()) {
            guard let key = $1.key as? NSRegularExpression, let value = $1.value as? DeeplinkResponder.Type else { return $0 }
            var mutableInitial = $0
            mutableInitial[key] = value
            return mutableInitial
        }
    }
}
