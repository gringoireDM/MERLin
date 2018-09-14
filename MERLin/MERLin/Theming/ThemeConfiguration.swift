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
    public static var defaultTheme: ModuleThemeProtocol {
        get {
            return objc_getAssociatedObject(self, &staticThemeHandle) as! ModuleThemeProtocol
        } set {
            objc_setAssociatedObject(self, &staticThemeHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            UIApplication.shared.windows.forEach { $0.defaultTheme = newValue }
        }
    }
    public var defaultTheme: ModuleThemeProtocol {
        get {
            return objc_getAssociatedObject(self, &themeHandle) as! ModuleThemeProtocol
        } set {
            objc_setAssociatedObject(self, &themeHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue.applyAppearance()
            guard let root = rootViewController else { return }
            
            UIWindow.traverseViewControllerStackApplyingTheme(from: root)
        }
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

public protocol Themed: UITraitEnvironment {
    func applyTheme()
}
