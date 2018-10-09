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

private var staticThemeHandle: UInt8 = 0
private var themeHandle: UInt8 = 0
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
        var queue = [root]
        while let controller = queue.first {
            queue.removeFirst()
            (controller as? Themed)?.applyTheme()
            queue += controller.children
            if let presented = controller.presentedViewController {
                queue += [presented]
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
