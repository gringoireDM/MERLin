//
//  MockModuleListener.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin
import RxSwift

class MockAnyModuleListener: AnyModuleEventsListener {
    var registeredProducers: [AnyModule] = []
    func listenEvents(from module: AnyEventsProducerModule) -> Bool {
        registeredProducers.append(module)
        return true
    }
}

class MockModuleListener<T: EventProtocol>: ModuleEventsListener {
    var registeredProducers: [AnyModule] = []
    func listenEvents(from module: AnyEventsProducerModule, events: Observable<T>) -> Bool {
        registeredProducers.append(module)
        return true
    }
}

class MockModuleListenersAggregator: ModuleEventsListenersAggregator {
    var moduleListeners: [AnyModuleEventsListener]
    var handledRoutingContext: [String]?
    
    init(withListeners listeners: [AnyModuleEventsListener], handledContexts: [String]? = nil) {
        moduleListeners = listeners
        handledRoutingContext = handledContexts
    }
}
