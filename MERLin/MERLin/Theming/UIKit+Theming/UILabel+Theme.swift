//
//  UILabel+Theme.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 23/04/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

public extension UILabel {
    public func applyLabelStyle(_ style: ThemeFontStyle, usingTheme theme: ThemeProtocol = ThemeManager.defaultTheme, customizing: ((UILabel, ThemeProtocol)->Void)? = nil) {
        theme.configure(label: self, withStyle: style, customizing: customizing)
    }
}

public extension Array where Element: UILabel {
    public func applyLabelStyle(_ style: ThemeFontStyle, usingTheme theme: ThemeProtocol = ThemeManager.defaultTheme, customizing: ((UILabel, ThemeProtocol)->Void)? = nil) {
        forEach {
            theme.configure(label: $0, withStyle: style, customizing: customizing)
        }
    }
}
