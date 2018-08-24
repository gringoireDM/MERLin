//
//  ModuleBuildContext.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 14/05/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

public protocol ModuleBuildContextProtocol {
    var routingContext: String { get }
}

public struct ModuleContext: ModuleBuildContextProtocol, Hashable {
    public let routingContext: String
    
    public init(routingContext: String = Module.defaultRoutingContext) {
        self.routingContext = routingContext
    }
}
