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
    static var priority: DeeplinkMatchingPriority = .high
    static var deeplinkSchemaNames: [String] = ["test", "anotherTest"]
    
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
        let testRegEx = try! NSRegularExpression(pattern: "\\btest\\:\\/\\/mock\\/?([0-9]*)", options: .caseInsensitive)
        let anotherTestRegEx = try! NSRegularExpression(pattern: "\\banotherTest\\:\\/\\/mock\\/?([0-9]*)", options: .caseInsensitive)
        
        return [testRegEx, anotherTestRegEx]
    }
}

class LowPriorityMockDeeplinkableModule: NSObject, ModuleProtocol, Deeplinkable {
    static var priority: DeeplinkMatchingPriority = .low
    static var deeplinkSchemaNames: [String] = ["test", "anotherTest"]
    
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
        let module = LowPriorityMockDeeplinkableModule(usingContext: ModuleContext(building: MockDeeplinkable.self))
        return (module, module.prepareRootViewController())
    }
    
    func deeplinkURL() -> URL? {
        return URL(string: "test://mock")
    }
    
    static func deeplinkRegexes() -> [NSRegularExpression]? {
        let testRegEx = try! NSRegularExpression(pattern: "\\btest\\:\\/\\/mock\\/?([0-9]*)", options: .caseInsensitive)
        let testProductRegEx = try! NSRegularExpression(pattern: "\\btest\\:\\/\\/.*product\\/?([0-9]+)", options: .caseInsensitive)
        let anotherTestRegEx = try! NSRegularExpression(pattern: "\\banotherTest\\:\\/\\/mock\\/?([0-9]*)", options: .caseInsensitive)
        let anotherTestProductRegEx = try! NSRegularExpression(pattern: "\\banotherTest\\:\\/\\/.*product\\/?([0-9]+)", options: .caseInsensitive)
        
        return [testRegEx, testProductRegEx, anotherTestRegEx, anotherTestProductRegEx]
    }
}
