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
    var make: () -> (AnyModule, UIViewController) { get }
}

public protocol ModuleContextProtocol: AnyModuleContextProtocol {
    associatedtype ModuleType: ModuleProtocol
}

public class ModuleContext: AnyModuleContextProtocol, Hashable {
    public let routingContext: String
    private var moduleType: String
    public var make: () -> (AnyModule, UIViewController) = { fatalError() }

    public init<Module: ModuleProtocol>(routingContext: String = "default", building moduleType: Module.Type)  where Module.Context == ModuleContext {
        self.routingContext = routingContext
        self.moduleType = String(describing: moduleType)
        self.make = { [unowned self] in
            let module = Module(usingContext: self)
            return (module, module.prepareRootViewController())
        }
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
    public var make: () -> (AnyModule, UIViewController) {
        return {
            let module = ModuleType(usingContext: self)
            return (module, module.prepareRootViewController())
        }
    }
}
