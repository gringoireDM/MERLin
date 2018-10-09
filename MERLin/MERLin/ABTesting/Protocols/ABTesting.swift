//
//  ABTesting.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 09/03/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol ABTesting {
    ///Get the state machine for the current instance to track the ready state of the manager
    var stateMachine: ABTestingManagerStateMachine { get }
    
    func startExperiment<T: ABExperiment>(_ experiment: T) -> T.Variation?
}
