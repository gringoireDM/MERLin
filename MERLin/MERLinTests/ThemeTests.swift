//
//  ThemeTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 14/09/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import MERLin

class ThemeTests: XCTestCase {
    override func setUp() {
        super.setUp()
        ThemeManager.defaultTheme = MockTheme()
    }
    
    func testThatItCanApplyThemeToRootViewController() {
        let root = MockViewController()
        UIWindow.traverseViewControllerStackApplyingTheme(from: root)
        XCTAssertEqual(root.applyTimes, 1)
    }
    
    func testThatItCanApplyThemeToChildren() {
        let root = MockViewController()
        let children = prepareChildren(for: root)
        
        UIWindow.traverseViewControllerStackApplyingTheme(from: root)

        for controller in [root]+children {
            XCTAssertEqual(controller.applyTimes, 1)
        }
    }
    
    func testThatItCanApplyThemeToArbitraryDepthOfChildren() {
        let root = MockViewController()
        let treeNodes = prepareHeavilyUnbalancedTree(withDepth: 10, havingRoot: root)
        
        UIWindow.traverseViewControllerStackApplyingTheme(from: root)

        for controller in [root]+treeNodes {
            XCTAssertEqual(controller.applyTimes, 1)
        }
    }
    
    func prepareHeavilyUnbalancedTree(withDepth depth: Int, havingRoot root: MockViewController) -> [MockViewController] {
        var treeNodes = prepareChildren(for: root)
        
        var currentRoot = root
        
        for _ in 0..<10 {
            for controller in currentRoot.children {
                treeNodes += prepareChildren(for: controller)
            }
            currentRoot = treeNodes.last!
        }

        return treeNodes
    }
    
    func prepareChildren(for root: UIViewController) -> [MockViewController] {
        let children = Array(repeating: MockViewController(), count: 10)
        children.forEach(root.addChild)
        return children
    }
    
    
}
