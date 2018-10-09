//
//  UIColor+Theme.swift
//  Module
//
//  Created by Giuseppe Lanza on 25/04/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import UIKit

extension UIColor {
    public static func color(forPalette palette: ThemeColorPalette, usingTheme theme: ThemeProtocol = ThemeManager.defaultTheme) -> UIColor {
        return theme.color(forColorPalette: palette)
    }
}
