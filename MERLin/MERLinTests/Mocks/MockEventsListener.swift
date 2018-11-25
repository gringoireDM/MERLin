//
//  MockEventsListener.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 25/11/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin

class MockAnyEventsListener: AnyEventsListening {
    var registeredProducers: [AnyEventsProducer] = []
    func registerToEvents(for producer: AnyEventsProducer) -> Bool {
        registeredProducers.append(producer)
        return true
    }
}

class MockEventsListener<E: EventProtocol>: EventsListening {
    var registeredProducers: [AnyEventsProducer] = []
    func registerToEvents(for producer: AnyEventsProducer, events: EventsProxy<E>) -> Bool {
        registeredProducers.append(producer)
        return true
    }
}

