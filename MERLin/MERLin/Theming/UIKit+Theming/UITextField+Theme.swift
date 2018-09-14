//
//  UITextField+Theme.swift
//  Module
//
//  Created by Giuseppe Lanza on 30/04/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

public extension UITextField {
    public func applyBoxedStyle(usingTheme theme: ModuleThemeProtocol = UIWindow.defaultTheme, withTextStyle style: ThemeFontStyle, customizing: ((UITextField, ModuleThemeProtocol)-> Void)? = nil) {
        theme.configureBoxedTextField(textfield: self, withTextStyle: style, customizing: customizing)
    }
}
