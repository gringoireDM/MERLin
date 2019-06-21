//
//  MockEventsConsumer.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 25/11/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin
import RxSwift

class MockAnyEventsConsumer: AnyEventsConsumer {
    var registeredProducers: [AnyEventsProducer] = []
    
    func consumeEvents(from producer: AnyEventsProducer) -> Bool {
        registeredProducers.append(producer)
        return true
    }
}

class MockEventsConsumer<E: EventProtocol>: EventsConsumer {
    var registeredProducers: [AnyEventsProducer] = []
    func consumeEvents(from producer: AnyEventsProducer, events: Observable<E>) -> Bool {
        registeredProducers.append(producer)
        return true
    }
}

class MockConsumersAggregator: EventsConsumersAggregator {
    var consumers: [AnyEventsConsumer]
    init(withConsumers consumers: [AnyEventsConsumer]) {
        self.consumers = consumers
    }
}
