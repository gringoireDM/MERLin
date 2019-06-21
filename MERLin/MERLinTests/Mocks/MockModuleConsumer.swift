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

class MockAnyModuleConsumer<T: EventProtocol>: AnyModuleEventsConsumer {
    func consumeEvents(from module: AnyEventsProducerModule) -> Bool {
        return true
    }
}

class MockModuleConsumer<T: EventProtocol>: ModuleEventsConsumer {
    func consumeEvents(from module: AnyEventsProducerModule, events: Observable<T>) -> Bool {
        return true
    }
}

class MockModuleConsumerAggregator: ModuleEventsConsumersAggregator {
    var moduleConsumers: [AnyModuleEventsConsumer]
    var handledRoutingContext: [String]?
    
    init(withConsumers consumers: [AnyModuleEventsConsumer], handledContexts: [String]?) {
        moduleConsumers = consumers
        handledRoutingContext = handledContexts
    }
}
