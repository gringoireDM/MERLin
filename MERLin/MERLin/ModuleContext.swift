//
//  ModuleBuildContext.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 14/05/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol AnyModuleContextProtocol {
    var routingContext: String { get }
    func make() -> (AnyModule, UIViewController)
}

public protocol ModuleContextProtocol: AnyModuleContextProtocol {
    associatedtype ModuleType: ModuleProtocol
}

public class ModuleContext: AnyModuleContextProtocol, Hashable {
    public let routingContext: String
    private var moduleType: String
    private var initializer: (ModuleContext) -> AnyModule

    public init<Module: ModuleProtocol>(routingContext: String = "default", building moduleType: Module.Type)  where Module.Context == ModuleContext {
        self.routingContext = routingContext
        self.moduleType = String(describing: moduleType)
        self.initializer = Module.init
    }
    
    public func make() -> (AnyModule, UIViewController) {
        let module = initializer(self)
        return (module, module.prepareRootViewController())
    }
    
    public static func == (lhs: ModuleContext, rhs: ModuleContext) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(routingContext)
        hasher.combine(moduleType)
    }
}

public extension ModuleContextProtocol where ModuleType.Context == Self {
    public func make() -> (AnyModule, UIViewController) {
        let module = ModuleType(usingContext: self)
        return (module, module.prepareRootViewController())
    }
}
