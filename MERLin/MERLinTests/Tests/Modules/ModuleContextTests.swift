//
//  ModuleContextTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 03/01/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

@testable import MERLin
import XCTest

class ModuleContextTests: XCTestCase {
    func testThatContextCanBuildModule() {
        let context = ModuleContext(routingContext: "test", building: MockModule<NoEvents>.self)
        let (module, _) = context.make()
        
        XCTAssert(module is MockModule<NoEvents>)
        XCTAssertEqual((module as? MockModule<NoEvents>)?.context, context)
    }
    
    func testThatContextCanBuildContextualizedModule() {
        let context = MockContext(routingContext: "test")
        let (module, _) = context.make()
        
        XCTAssert(module is ContextualizedMockModule)
        XCTAssertEqual((module as? ContextualizedMockModule)?.context, context)
    }
}
