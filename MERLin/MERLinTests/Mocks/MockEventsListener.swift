//
//  MockEventsListener.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 25/11/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin
import RxSwift

class MockAnyEventsListener: AnyEventsListener {
    var registeredProducers: [AnyEventsProducer] = []
    func listenEvents(from producer: AnyEventsProducer) -> Bool {
        registeredProducers.append(producer)
        return true
    }
}

class MockEventsListener<E: EventProtocol>: EventsListener {
    var registeredProducers: [AnyEventsProducer] = []
    func listenEvents(from producer: AnyEventsProducer, events: Observable<E>) -> Bool {
        registeredProducers.append(producer)
        return true
    }
}

class MockListenersAggregator: EventsListenersAggregator {
    var listeners: [AnyEventsListener]
    init(withListeners listeners: [AnyEventsListener]) {
        self.listeners = listeners
    }
}
