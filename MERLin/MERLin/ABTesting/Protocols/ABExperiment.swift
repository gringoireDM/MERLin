//
//  ABExperiment.swift
//  ABTestingManager
//
//  Created by Giuseppe Lanza on 09/03/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol ABExperiment: class {
    associatedtype Variation: ABVariation
    
    var name: String { get }
    var userId: String { get }
    var parameters: [String: String]? { get }
    
    var variation: Variation? { get set }
}

public extension ABExperiment {
    public var isActive: Bool { return variation != nil }
}
