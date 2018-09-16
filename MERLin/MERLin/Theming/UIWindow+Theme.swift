//
//  ThemeConfiguration.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 14/09/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

private var staticThemeHandle: UInt8 = 0
private var themeHandle: UInt8 = 0
public extension UIWindow {
    public static var defaultTheme: ThemeProtocol {
        get {
            return objc_getAssociatedObject(self, &staticThemeHandle) as! ThemeProtocol
        } set {
            objc_setAssociatedObject(self, &staticThemeHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            UIApplication.shared.windows.forEach { window in
                guard window.theme === newValue else { return }
                window.applyTheme(newValue)
            }
        }
    }
    
    public var theme: ThemeProtocol {
        get {
            return objc_getAssociatedObject(self, &themeHandle) as? ThemeProtocol ?? UIWindow.defaultTheme
        } set {
            objc_setAssociatedObject(self, &themeHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            applyTheme(theme)
        }
    }
    
    func applyTheme(_ theme: ThemeProtocol) {
        theme.applyAppearance()
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
        guard overrideLocal || theme === UIWindow.defaultTheme else { return }
        applyTheme(UIWindow.defaultTheme)
    }
}

public protocol Themed: UITraitEnvironment {
    func applyTheme()
}
