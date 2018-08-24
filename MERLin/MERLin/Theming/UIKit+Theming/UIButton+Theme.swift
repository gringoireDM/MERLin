//
//  UIButton+Theme.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 23/04/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

public extension UIButton {
    public func applyPrimaryButtonStyle(usingTheme theme: ModuleThemeProtocol = Module.defaultTheme, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ModuleThemeProtocol)-> Void)? = nil) {
        theme.configurePrimaryButton(button: self, withTitleStyle: style, customizing: customizing)
    }
    
    public func applySecondaryButtonStyle(usingTheme theme: ModuleThemeProtocol = Module.defaultTheme, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ModuleThemeProtocol)-> Void)? = nil) {
        theme.configureSecondaryButton(button: self, withTitleStyle: style, customizing: customizing)
    }
    
    public func applyTextOnlyButtonStyle(usingTheme theme: ModuleThemeProtocol = Module.defaultTheme, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ModuleThemeProtocol)-> Void)? = nil) {
        theme.configureTextOnlyButton(button: self, withTitleStyle: style, customizing: customizing)
    }
}

public extension Array where Element: UIButton {
    public func applyPrimaryButtonStyle(usingTheme theme: ModuleThemeProtocol = Module.defaultTheme, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ModuleThemeProtocol)-> Void)? = nil) {
        forEach {
            theme.configurePrimaryButton(button: $0, withTitleStyle: style, customizing: customizing)
        }
    }
    
    public func applySecondaryButtonStyle(usingTheme theme: ModuleThemeProtocol = Module.defaultTheme, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ModuleThemeProtocol)-> Void)? = nil) {
        forEach {
            theme.configureSecondaryButton(button: $0, withTitleStyle: style, customizing: customizing)
        }
    }
    
    public func applyTextOnlyButtonStyle(usingTheme theme: ModuleThemeProtocol = Module.defaultTheme, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ModuleThemeProtocol)-> Void)? = nil) {
        forEach{
            theme.configureTextOnlyButton(button: $0, withTitleStyle: style, customizing: customizing)
        }
    }

}
