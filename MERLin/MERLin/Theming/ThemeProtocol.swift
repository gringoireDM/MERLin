//
//  ThemeProtocol.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/04/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

public enum ThemeFontAttribute {
    case regular
    case bold
    case sBold
}

public enum ThemeColorPalette {
    case white
    case gray_1
    case gray_2
    case gray_3
    case gray_4
    case black
    case primary
    case primaryFocused
    case error
    case warning
    case success
    case info
    case sales
    case custom(color: UIColor)
}

public enum ThemeFontStyle {
    case small(attribute: ThemeFontAttribute)
    case caption(attribute: ThemeFontAttribute)
    case subhead(attribute: ThemeFontAttribute)
    case body(attribute: ThemeFontAttribute)
    case headline(attribute: ThemeFontAttribute)
    case title(attribute: ThemeFontAttribute)
    case display(attribute: ThemeFontAttribute)
    
    public var attribute: ThemeFontAttribute {
        switch self {
        case .small(let attribute): return attribute
        case .caption(let attribute): return attribute
        case .subhead(let attribute): return attribute
        case .body(let attribute): return attribute
        case .headline(let attribute): return attribute
        case .title(let attribute): return attribute
        case .display(let attribute): return attribute
        }
    }
}

public protocol ThemeProtocol: class {
    var appearanceRules: [AppearanceReversible] { get }
    
    //MARK: Colors
    func color(forColorPalette colorPalette: ThemeColorPalette) -> UIColor
    
    //MARK: Fonts
    func font(forStyle style: ThemeFontStyle) -> UIFont
    func fontSize(forStyle style: ThemeFontStyle) -> CGFloat
    
    //MARK: Buttons
    @discardableResult func configurePrimaryButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol)->Void)?) -> UIButton
    @discardableResult func configureSecondaryButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol)->Void)?) -> UIButton
    @discardableResult func configureTextOnlyButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol)->Void)?) -> UIButton
    
    //MARK: Labels
    func attributedString(withString string: String, andStyle style: ThemeFontStyle) -> NSAttributedString
    func configure(range: NSRange, of attributedString: NSAttributedString, withStyle style: ThemeFontStyle, andColor color: ThemeColorPalette) -> NSAttributedString
    @discardableResult
    func configure(label: UILabel, withStyle style: ThemeFontStyle, customizing: ((UILabel, ThemeProtocol)->Void)?) -> UILabel
    
    //MARK: Text Fields
    @discardableResult
    func configureBoxedTextField(textfield: UITextField, withTextStyle style: ThemeFontStyle, customizing: ((UITextField, ThemeProtocol)->Void)?) -> UITextField
    
    ///This method should return a fresh instance of theme with default values.
    func cleanThemeCopy() -> Self
}
