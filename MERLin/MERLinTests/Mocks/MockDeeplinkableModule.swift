//
//  MockDeeplinkableModule.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin

class MockViewController: UIViewController {}

class MockDeeplinkable: NSObject, ModuleProtocol, Deeplinkable {
    static var deeplinkSchemaNames: [String] = ["test"]
    
    var context: ModuleContext
    
    required init(usingContext buildContext: ModuleContext) {
        context = buildContext
        super.init()
    }
    
    func unmanagedRootViewController() -> UIViewController {
        return MockViewController()
    }
    
    static func classForDeeplinkingViewController() -> UIViewController.Type {
        return MockViewController.self
    }
    
    static func module(fromDeeplink deeplink: String) -> (AnyModule, UIViewController)? {
        let module = MockDeeplinkable(usingContext: ModuleContext(building: MockDeeplinkable.self))
        return (module, module.prepareRootViewController())
    }
    
    func deeplinkURL() -> URL? {
        return URL(string: "test://mock")
    }
    
    static func deeplinkRegexes() -> [NSRegularExpression]? {
        let regEx = try! NSRegularExpression(pattern: "\\btest\\:\\/\\/mock\\/?([0-9]*)", options: .caseInsensitive)
        let productRegEx = try! NSRegularExpression(pattern: "\\btest\\:\\/\\/product\\/?([0-9]+)", options: .caseInsensitive)
        return [regEx, productRegEx]
    }
}
