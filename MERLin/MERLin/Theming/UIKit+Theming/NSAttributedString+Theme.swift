//
//  NSAttributedString+Theme.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 25/04/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

public extension NSAttributedString {
    public static func attributedString(withString string: String, andStyle style: ThemeFontStyle, usingTheme theme: ThemeProtocol = ThemeManager.defaultTheme) -> NSAttributedString {
        return theme.attributedString(withString: string, andStyle: style)
    }
    
    public static func attributedString(fromHTML string: String, andStyle style: ThemeFontStyle, usingTheme theme: ThemeProtocol = ThemeManager.defaultTheme) -> NSAttributedString {
        guard let data = string.data(using: .utf8) else { return NSAttributedString() }
        do {
            let attributes: [NSAttributedString.DocumentReadingOptionKey: Any] =
                [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                 NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue]
            let htmlString = try NSMutableAttributedString(data: data, options: attributes, documentAttributes: nil).string
            return attributedString(withString: htmlString, andStyle: style)
        } catch {
            return NSAttributedString()
        }
    }
    
    public func applyStyle(_ style: ThemeFontStyle, andColor color: ThemeColorPalette, toRange range: NSRange, usingTheme theme: ThemeProtocol = ThemeManager.defaultTheme) -> NSAttributedString {
        return theme.configure(range: range, of: self, withStyle: style, andColor: color)
    }
}
