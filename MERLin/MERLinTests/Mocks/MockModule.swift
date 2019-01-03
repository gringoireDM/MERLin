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

struct NoEvents: EventProtocol, Equatable { }

struct MockContext: ModuleContextProtocol, Equatable {
    typealias ModuleType = ContextualizedMockModule
    var routingContext: String
}

class ContextualizedMockModule: NSObject, ModuleProtocol {
    var context: MockContext

    required init(usingContext buildContext: MockContext) {
        context = buildContext
        super.init()
    }
    
    func unmanagedRootViewController() -> UIViewController {
        return UIViewController()
    }
}

class MockModule: NSObject, ModuleProtocol, EventsProducer {
    var context: ModuleContext
    
    var moduleName: String = "MockModule"
    var moduleSection: String = "ModuleTests"
    var moduleType: String = "test"
    
    var events: Observable<NoEvents> = PublishSubject<NoEvents>()
    required init(usingContext buildContext: ModuleContext) {
        context = buildContext
        super.init()
    }
    
    func unmanagedRootViewController() -> UIViewController {
        return UIViewController()
    }
}

extension ModuleRoutingStep {
    static func mock() -> ModuleRoutingStep {
        return ModuleRoutingStep(withMaker: ModuleContext(building: MockModule.self))
    }
}
