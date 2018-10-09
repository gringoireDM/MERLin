//
//  UIFont+Theme.swift
//  Module
//
//  Created by Giuseppe Lanza on 25/04/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

public extension UIFont {
    public static func font(forStyle style: ThemeFontStyle, usingTheme theme: ThemeProtocol = ThemeManager.defaultTheme) -> UIFont {
        return theme.font(forStyle: style)
    }
}
