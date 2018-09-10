//
//  MockModule.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 10/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin
import RxSwift

struct NoEvents: EventProtocol { }

class MockModule: NSObject, ModuleProtocol, EventsProducer {
    var context: ModuleContext
    
    var moduleName: String = "MockModule"
    var moduleSection: String = "ModuleTests"
    var moduleType: String = "test"
    var eventsType: EventProtocol.Type = NoEvents.self
    
    var events: Observable<EventProtocol> = PublishSubject<EventProtocol>()
    required init(usingContext buildContext: ModuleContext) {
        context = buildContext
        super.init()
    }
    
    func unmanagedRootViewController() -> UIViewController {
        return UIViewController()
    }
}

struct MockStep: ModuleMaking {
    var routingContext: String = ""
    
    var make: () -> (AnyModule, UIViewController) {
        return {
            return (MockModule(usingContext: ModuleContext()), MockViewController())
        }
    }
}

extension ModuleRoutingStep {
    static func mock() -> ModuleRoutingStep {
        return ModuleRoutingStep(withMaker: MockStep())
    }
}
