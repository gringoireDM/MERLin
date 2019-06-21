//
//  MockModuleConsumer.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin
import RxSwift

class MockAnyModuleConsumer: AnyModuleEventsConsumer {
    var registeredProducers: [AnyModule] = []
    func consumeEvents(from module: AnyEventsProducerModule) -> Bool {
        registeredProducers.append(module)
        return true
    }
}

class MockModuleConsumer<T: EventProtocol>: ModuleEventsConsumer {
    var registeredProducers: [AnyModule] = []
    func consumeEvents(from module: AnyEventsProducerModule, events: Observable<T>) -> Bool {
        registeredProducers.append(module)
        return true
    }
}

class MockModuleConsumerAggregator: ModuleEventsConsumersAggregator {
    var moduleConsumers: [AnyModuleEventsConsumer]
    var handledRoutingContext: [String]?
    
    init(withConsumers consumers: [AnyModuleEventsConsumer], handledContexts: [String]? = nil) {
        moduleConsumers = consumers
        handledRoutingContext = handledContexts
    }
}
