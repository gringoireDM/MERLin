//
//  MockTheme.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 14/09/18.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin

extension ThemeColorPalette {
    var color: UIColor {
        switch self {
        case .white: return .white
        case .gray_1, .gray_2, .gray_3, .gray_4: return .gray
        case .black: return .black
        case .primary: return .blue
        case .primaryFocused: return .cyan
        case .error: return .red
        case .warning: return .yellow
        case .success: return .green
        case .info: return .lightGray
        case .sales: return .purple
        case .custom(let color): return color
        }
    }
}

private extension ThemeFontAttribute {
    func primaryFont(withSize size: CGFloat = UIFont.labelFontSize) -> UIFont {
        switch self {
        case .regular: return .systemFont(ofSize: size)
        case .bold: return .boldSystemFont(ofSize: size)
        case .sBold: return .systemFont(ofSize: size, weight: .semibold)
        }
    }
}

private extension ThemeFontStyle {
    var fontSize: CGFloat {
        switch self {
        case .small(_): return 11
        case .caption(_): return 12
        case .subhead(_): return 13
        case .body(_): return 15
        case .headline(_): return 18
        case .title(_): return 22
        case .display(_): return 26
        }
    }
    
    var font: UIFont {
        return attribute.primaryFont(withSize: fontSize)
    }
}

final class MockTheme: ThemeProtocol {
    func color(forColorPalette colorPalette: ThemeColorPalette) -> UIColor {
        return colorPalette.color
    }
    
    func configurePrimaryButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol) -> Void)?) -> UIButton {
        button.titleLabel?.font = style.font
        customizing?(button, self)
        return button
    }
    
    func configureSecondaryButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol) -> Void)?) -> UIButton {
        button.titleLabel?.font = style.font
        customizing?(button, self)
        return button
    }
    
    func configureTextOnlyButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol) -> Void)?) -> UIButton {
        button.titleLabel?.font = style.font
        customizing?(button, self)
        return button
    }
    
    func attributedString(withString string: String, andStyle style: ThemeFontStyle) -> NSAttributedString {
        let attributedString = NSAttributedString(string: string,
                                                  attributes: [
                                                    .font: style.font,
                                                    .foregroundColor: color(forColorPalette: .gray_4) ])
        
        return attributedString
    }
    
    func configure(range: NSRange, of attributedString: NSAttributedString, withStyle style: ThemeFontStyle, andColor color: ThemeColorPalette) -> NSAttributedString {
        let mutableCopy = attributedString.mutableCopy() as! NSMutableAttributedString
        
        mutableCopy.setAttributes([
            NSAttributedString.Key.font: style.font,
            NSAttributedString.Key.foregroundColor: self.color(forColorPalette: color)
            ], range: range)
        
        return mutableCopy
    }
    
    func configure(label: UILabel, withStyle style: ThemeFontStyle, customizing: ((UILabel, ThemeProtocol) -> Void)?) -> UILabel {
        label.font = style.font
        customizing?(label, self)
        return label
    }
    
    func configureBoxedTextField(textfield: UITextField, withTextStyle style: ThemeFontStyle, customizing: ((UITextField, ThemeProtocol) -> Void)?) -> UITextField {
        textfield.font = font(forStyle: style)
        customizing?(textfield, self)
        return textfield
    }
    
    func font(forStyle style: ThemeFontStyle) -> UIFont {
        return style.font
    }
    
    func fontSize(forStyle style: ThemeFontStyle) -> CGFloat {
        return style.fontSize
    }
    
    func applyAppearance() { }
    
    final func cleanThemeCopy() -> MockTheme {
        return MockTheme()
    }
}
