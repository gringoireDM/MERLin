//
//  ModuleTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 03/01/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import MERLin

class ModuleTests: XCTestCase {
    var module: MockModule!
    override func setUp() {
        super.setUp()
        module = MockModule(usingContext: ModuleContext(building: MockModule.self))
    }
    
    override func tearDown() {
        module = nil
        super.tearDown()
    }
    func testItCanStoreRootViewController() {
        let viewController = UIViewController()
        module.rootViewController = viewController
        
        XCTAssert(viewController === module.rootViewController)
    }
    
    func testItCanThrowRootviewController() {
        let viewController = UIViewController()
        module.rootViewController = viewController
        module.rootViewController = nil
        XCTAssertNil(module.rootViewController)
    }
    
    func testThatItHasWeakReferenceToViewController() {
        var viewController: UIViewController? = UIViewController()
        module.rootViewController = viewController
        autoreleasepool { viewController = nil }
        XCTAssertNil(module.rootViewController)
    }
    
    func testThatCanPrepareRootViewController() {
        let controller = module.prepareRootViewController()
        XCTAssert(controller === module.rootViewController)
    }
    
    func testThatCanReusePreviouslyPreparedRootViewController() {
        let controller = module.prepareRootViewController()
        let cachedController = module.prepareRootViewController()
        XCTAssert(controller === cachedController)
    }
    
    func testThatDisposeBagIsUnique() {
        let disposeBag = module.disposeBag
        let cachedDisposeBag = module.disposeBag
        XCTAssert(disposeBag === cachedDisposeBag)
    }
}
