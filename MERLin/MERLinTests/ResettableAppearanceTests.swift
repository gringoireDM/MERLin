//
//  ResettableAppearanceTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 16/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import MERLin

class MockView: UIView { }
class MockView2: MockView { }
class MockTabBar: UITabBar { }
class MockTableView: UITableView { }
class MockNavigationBar: UINavigationBar { }

class ResettableAppearanceTests: XCTestCase {
    
    func testThatItCanStoreAppearance() {
        let viewAppearance = ResettableAppearence<MockView>()
        MockView.resettableAppearance = viewAppearance
        XCTAssertTrue(MockView.resettableAppearance === viewAppearance)
    }
    
    func testThatCanHandleCollisions() {
        let viewAppearance = ResettableAppearence<MockView>()
        MockView.resettableAppearance = viewAppearance
        
        let secondViewAppearance = ResettableAppearence<MockView2>()
        MockView2.resettableAppearance = secondViewAppearance
        XCTAssertTrue(MockView.resettableAppearance === viewAppearance)
        XCTAssertTrue(MockView2.resettableAppearance === secondViewAppearance)
    }
    
    func testThatItCanStoreMutlipleAppearances() {
        let viewAppearance = ResettableAppearence<MockView>()
        MockView.resettableAppearance = viewAppearance

        let tabBarAppearance = ResettableAppearence<MockTabBar>()
        MockTabBar.resettableAppearance = tabBarAppearance
        XCTAssertTrue(MockView.resettableAppearance === viewAppearance)
        XCTAssertTrue(MockTabBar.resettableAppearance === tabBarAppearance)
    }
    
    func testThatItCanApplyAppearance() {
        let expectedColor = UIColor.black
        let viewAppearance = ResettableAppearence<MockView>(){ view in
            view.backgroundColor = expectedColor
        }
        MockView.resettableAppearance = viewAppearance
        
        let view = MockView(frame: .zero)
        view.applyAppearence()
        XCTAssertEqual(view.backgroundColor, expectedColor)
    }
    
    func testThatItCanApplyAppearenceWhenMovedToAWindow() {
        let window = UIWindow()
        let expectedColor = UIColor.black
        let viewAppearance = ResettableAppearence<MockView>(){ view in
            view.backgroundColor = expectedColor
        }
        MockView.resettableAppearance = viewAppearance
        
        let view = MockView(frame: .zero)
        window.addSubview(view)
        XCTAssertEqual(view.backgroundColor, expectedColor)
    }

    func testThatItCanApplyAppearenceRecursively() {
        let window = UIWindow()
        let expectedColor = UIColor.black
        let viewAppearance = ResettableAppearence<MockView>(){ view in
            view.backgroundColor = expectedColor
        }
        let secondAppearance = ResettableAppearence<MockView2>() { view in
            view.tintColor = expectedColor
        }
        
        MockView.resettableAppearance = viewAppearance
        MockView2.resettableAppearance = secondAppearance
        let view = MockView2(frame: .zero)
        window.addSubview(view)
        XCTAssertEqual(view.backgroundColor, expectedColor)
        XCTAssertEqual(view.tintColor, expectedColor)
    }
    
    func testThatItCanResetAppearance() {
        let viewAppearance = ResettableAppearence<MockView>()
        MockView.resettableAppearance = viewAppearance

        AppearanceProxy.resetAppearences()
        XCTAssertNil(MockView.resettableAppearance)
    }
}
