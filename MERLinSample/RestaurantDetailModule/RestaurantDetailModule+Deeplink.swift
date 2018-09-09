//
//  RestaurantDetailModule+Deeplink.swift
//  RestaurantDetailModule
//
//  Created by Giuseppe Lanza on 15/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation


extension RestaurantDetailModule: DeeplinkContextUpdatable {
    public static var deeplinkSchemaNames: [String] = ["rest"]
    public static func deeplinkRegexes() -> [NSRegularExpression]? {
        guard deeplinkSchemaNames.count > 0 else { return nil }
        
        var regexString = "\\b("
        regexString += deeplinkSchemaNames.joined(separator: "|") + ")\\:\\/\\/"
        regexString += "rdp\\/([A-Za-z0-9]+)"
        
        let regex = try! NSRegularExpression(pattern: regexString, options: .caseInsensitive)
        return [regex]
    }
    
    public static func classForDeeplinkingViewController() -> UIViewController.Type {
        return type(of: UIStoryboard.restaurant.instantiateInitialViewController()!)
    }
    
    public func deeplinkURL() -> URL? {
        guard let schema = RestaurantDetailModule.deeplinkSchemaNames.first else { return nil }
        return URL(string: "\(schema)://rdp/\(context.id)")!
    }
    
    private static func context(fromDeeplink deeplink: String) -> RestaurantDetailBuildContext? {
        guard let match = deeplinkRegexes()?.compactMap({ $0.firstMatch(in: deeplink, range: NSRange(location: 0, length: deeplink.count)) }).first,
            let idRange = Range(match.range(at: match.numberOfRanges-1), in: deeplink) else { return nil }
        
        let id = String(deeplink[idRange])
        return RestaurantDetailBuildContext(withRoutingContext: "Deeplink", restaurantId: id)
    }
    
    static public func module(fromDeeplink deeplink: String) -> (AnyModule, UIViewController)? {
        guard let context = RestaurantDetailModule.context(fromDeeplink: deeplink) else { return nil }
        
        let module = RestaurantDetailModule(usingContext: context)
        return (module, module.prepareRootViewController())
    }
    
    @discardableResult public func updateContext(fromDeeplink deeplink: String) -> Bool {
        return false //don't want to replace the current restaurant on screen if any.
    }
}

//Adding deeplink knowledge for ProductIdentifying
public extension RestaurantProtocol {
    public var deeplinkURL: URL? {
        guard let schema = RestaurantDetailModule.deeplinkSchemaNames.first else { return nil }
        return URL(string: "\(schema)://rdp/\(id)")!
    }
}
