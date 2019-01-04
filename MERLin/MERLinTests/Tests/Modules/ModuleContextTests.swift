//
//  ModuleContextTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 03/01/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import MERLin

class ModuleContextTests: XCTestCase {
    func testThatContextCanBuildModule() {
        let context = ModuleContext(routingContext: "test", building: MockModule.self)
        let (module, _) = context.make()
        
        XCTAssert(module is MockModule)
        XCTAssertEqual((module as? MockModule)?.context, context)
    }
    
    func testThatContextCanBuildContextualizedModule() {
        let context = MockContext(routingContext: "test")
        let (module, _) = context.make()
        
        XCTAssert(module is ContextualizedMockModule)
        XCTAssertEqual((module as? ContextualizedMockModule)?.context, context)
    }
}
