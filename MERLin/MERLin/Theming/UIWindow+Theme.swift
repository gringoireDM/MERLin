//
//  ThemeConfiguration.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 14/09/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public class ThemeManager {
    public static var defaultTheme: ThemeProtocol! {
        didSet {
            if let old = oldValue {
                old.appearanceRules.revert()
            }
            
            UIApplication.shared.windows.forEach { window in
                window.applyTheme(defaultTheme)
            }
        }
    }
}

public extension UIWindow {
    func applyTheme(_ theme: ThemeProtocol) {
        theme.appearanceRules.apply()
        for view in subviews {
            view.removeFromSuperview()
            addSubview(view)
        }
        
        guard let root = rootViewController else { return }
        UIWindow.traverseViewControllerStackApplyingTheme(from: root)
    }

    static func traverseViewControllerStackApplyingTheme(from root: UIViewController) {
        //Standard bredth first traversal. View stack is a tree, therefore
        //no visited set is needed.
        var queue = Set([root])
        var visited = Set<UIViewController>()
        
        while let controller = queue.first {
            queue.removeFirst()
            visited.insert(controller)
            (controller as? Themed)?.applyTheme()
            controller.children.forEach { queue.insert($0) }
            if let presented = controller.presentedViewController,
                !visited.contains(presented) {
                queue.insert(presented)
            }
        }
    }
}

@objc public extension UIWindow {
    @objc public func applyDefaultTheme(overrideLocal: Bool) {
        applyTheme(ThemeManager.defaultTheme)
    }
}

public protocol Themed: UITraitEnvironment {
    func applyTheme()
}
