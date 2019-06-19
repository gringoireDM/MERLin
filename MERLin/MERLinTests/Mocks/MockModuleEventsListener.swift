//
//  MockModuleEventsListener.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin
import RxSwift

class MockAnyModuleListener<T: EventProtocol>: AnyModuleListening {
    func handleEvents(for module: AnyEventsProducer & AnyModule) -> Bool {
        return true
    }
}

class MockModuleListener<T: EventProtocol>: ModuleListening {
    func handleEvents(for module: AnyEventsProducer & AnyModule, events: Observable<T>) -> Bool {
        return true
    }
}

class MockModuleListenerAggregator: ModuleEventsListenerAggregator {
    var moduleListeners: [AnyModuleListening]
    var handledRoutingContext: [String]
    
    init(withListeners listeners: [AnyModuleListening], handledContexts: [String]) {
        moduleListeners = listeners
        handledRoutingContext = handledContexts
    }
}
