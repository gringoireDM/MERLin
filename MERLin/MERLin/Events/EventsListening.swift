//
//  EventManager.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 08/02/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public protocol EventsListening: class {
    ///This method allows the event manager to register to a module's events.
    ///- parameter moduel: The module exposing the events
    ///- returns: Bool indicating if the module's events can be handled by the event manager
    @discardableResult func registerToEvents(for producer: EventsProducer) -> Bool
}

