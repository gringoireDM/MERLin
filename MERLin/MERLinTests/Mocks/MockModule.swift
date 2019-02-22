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

struct NoEvents: EventProtocol, Equatable {}

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

class MockModule: NSObject, ModuleProtocol, EventsProducer, PageRepresenting {
    var context: ModuleContext
    
    var pageName: String = "MockModule"
    var section: String = "ModuleTests"
    var pageType: String = "test"
    
    var events: Observable<NoEvents> = PublishSubject<NoEvents>()
    required init(usingContext buildContext: ModuleContext) {
        context = buildContext
        super.init()
    }
    
    func unmanagedRootViewController() -> UIViewController {
        return MockViewController()
    }
}

extension ModuleRoutingStep {
    static func mock() -> ModuleRoutingStep {
        return ModuleRoutingStep(withMaker: ModuleContext(building: MockModule.self))
    }
}
