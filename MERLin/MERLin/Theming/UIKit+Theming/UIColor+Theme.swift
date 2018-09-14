//
//  UIColor+Theme.swift
//  Module
//
//  Created by Giuseppe Lanza on 25/04/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

extension UIColor {
    public static func color(forPalette palette: ThemeColorPalette, usingTheme theme: ModuleThemeProtocol = UIWindow.defaultTheme) -> UIColor {
        return theme.color(forColorPalette: palette)
    }
}
