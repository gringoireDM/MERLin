//
//  ModuleEvent.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/03/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

public protocol EventsDescriptor: class {
    var viewControllerOnScreen: BehaviorSubject<Bool>? { get }
    var allEventsDescriptions: [Observable<String>] { get }
    
    @discardableResult
    func attempt<T: EventsDescriptor>(toPerform closure: (T) -> Void) -> EventsDescriptor
}

public extension EventsDescriptor {
    @discardableResult
    func attempt<T: EventsDescriptor>(toPerform closure: (T) -> Void) -> EventsDescriptor {
        guard let typedSelf = self as? T else { return self }
        closure(typedSelf)
        return self
    }
}
