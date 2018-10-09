//
//  ChristmasTheme.swift
//  MERLinSample
//
//  Created by Giuseppe Lanza on 16/09/2018.
//  Copyright © 2018 HBCDigital. All rights reserved.
//


import UIKit
import MERLin

fileprivate extension ThemeFontAttribute {
    func primaryFont(withSize size: CGFloat = UIFont.labelFontSize) -> UIFont {
        switch self {
        case .regular: return .systemFont(ofSize: size)
        case .bold: return .boldSystemFont(ofSize: size)
        case .sBold: return .systemFont(ofSize: size, weight: .semibold)
        }
    }
}

fileprivate extension ThemeFontStyle {
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

fileprivate extension ThemeColorPalette {
    var color: UIColor {
        switch self {
        case .white: return .white
        case .gray_1: return .color(fromHex: "#f7f7f7")
        case .gray_2: return .color(fromHex: "#dedede")
        case .gray_3: return .color(fromHex: "#9e9e9e")
        case .gray_4: return .color(fromHex: "#3d3d3d")
        case .black: return .color(fromHex: "#1a1a1a")
        case .primary: return .color(fromHex: "#d42426")
        case .primaryFocused: return .color(fromHex: "#e04b4c")
        case .error: return .color(fromHex: "#ff0000")
        case .warning: return .color(fromHex: "#d58d24")
        case .success: return .color(fromHex: "#22b21e")
        case .info: return .color(fromHex: "#1e5db2")
        case .sales: return .color(fromHex: "#22b21e")
        }
    }
}

final class ChristmasTheme: ThemeProtocol {
    lazy var appearanceRules: [AppearanceReversible] = {
        let navigationAppearance: [AppearanceReversible] = [
            PropertyAppearanceRule(proxy: UINavigationBar.appearance(), keypath: \.isTranslucent, value: false),
            PropertyAppearanceRule(proxy: UINavigationBar.appearance(), keypath: \UINavigationBar.barTintColor, value: color(forColorPalette: .primary)),
            PropertyAppearanceRule<UINavigationBar, UIColor?>(proxy: UINavigationBar.appearance(), keypath: \.tintColor, value: .white),
            PropertyAppearanceRule(proxy: UINavigationBar.appearance(), keypath: \.titleTextAttributes, value: [
                .font: font(forStyle: .headline(attribute: .bold)),
                .foregroundColor: color(forColorPalette: .success)
                ])
        ]

        let barButtonAppearance: [AppearanceReversible] = [
            SelectorAppearanceRule(proxy: UIBarButtonItem.appearance(),
                                   get: { $0.titleTextAttributes(for: .normal) },
                                   set: { $0.setTitleTextAttributes($1, for: .normal) },
                                   value: [
                                    .font: font(forStyle: .body(attribute: .regular)),
                                    .foregroundColor: color(forColorPalette: .white)
                ]),
            SelectorAppearanceRule(proxy: UIBarButtonItem.appearance(),
                                   get: { $0.titleTextAttributes(for: .highlighted) },
                                   set: { $0.setTitleTextAttributes($1, for: .highlighted) },
                                   value: [
                                    .font: font(forStyle: .body(attribute: .regular)),
                                    .foregroundColor: color(forColorPalette: .gray_4)
                ]),
            SelectorAppearanceRule(proxy: UIBarButtonItem.appearance(),
                                   get: { $0.titleTextAttributes(for: .disabled) },
                                   set: { $0.setTitleTextAttributes($1, for: .disabled) },
                                   value: [
                                    .font: font(forStyle: .body(attribute: .regular)),
                                    .foregroundColor: color(forColorPalette: .gray_3)
                ])
        ]

        let tabBarAppearance: [AppearanceReversible] = [
            PropertyAppearanceRule(proxy: UITabBar.appearance(), keypath: \.isTranslucent, value: false),
            PropertyAppearanceRule(proxy: UITabBar.appearance(), keypath: \.barTintColor, value: .white),
            PropertyAppearanceRule<UITabBar, UIColor?>(proxy: UITabBar.appearance(), keypath: \.tintColor, value: color(forColorPalette: .primary))
        ]

        let tabBarItemAppearance: [AppearanceReversible] = [
            PropertyAppearanceRule(proxy: UITabBarItem.appearance(), keypath: \UITabBarItem.badgeColor, value: color(forColorPalette: .primary)),
            SelectorAppearanceRule(proxy: UITabBarItem.appearance(),
                                   get: { $0.titleTextAttributes(for: .selected) },
                                   set: { $0.setTitleTextAttributes($1, for: .selected) },
                                   value: [
                                    .font: font(forStyle: .small(attribute: .regular)),
                                    .foregroundColor: color(forColorPalette: .primary)
                ])
        ]

        
        return navigationAppearance + barButtonAppearance + tabBarAppearance + tabBarItemAppearance + [
            PropertyAppearanceRule(proxy: UITextField.appearance(whenContainedInInstancesOf:[UISearchBar.self]), keypath: \.defaultTextAttributes, value: convertToNSAttributedStringKeyDictionary([
                NSAttributedString.Key.font.rawValue: font(forStyle: .body(attribute: .regular)),
                NSAttributedString.Key.foregroundColor.rawValue: color(forColorPalette: .gray_4)
                ]))
        ]
    }()
    
    func color(forColorPalette colorPalette: ThemeColorPalette) -> UIColor {
        return colorPalette.color
    }
    
    func font(forStyle style: ThemeFontStyle) -> UIFont {
        return style.font
    }
    
    func fontSize(forStyle style: ThemeFontStyle) -> CGFloat {
        return style.fontSize
    }
    
    func cleanThemeCopy() -> ChristmasTheme {
        return ChristmasTheme()
    }
}

//MARK: - Labels

extension ChristmasTheme {
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
    
    @discardableResult
    func configure(label: UILabel, withStyle style: ThemeFontStyle, customizing: ((UILabel, ThemeProtocol)->Void)?) -> UILabel {
        label.font = style.font
        label.textColor = color(forColorPalette: .gray_4)
        
        customizing?(label, self)
        
        return label
    }
}

//MARK: - Buttons

extension ChristmasTheme {
    @discardableResult
    func configurePrimaryButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol)->Void)? = nil) -> UIButton {
        button.setupTitle(font: style.font)
            .setupLayer(cornerRadius: 2, borderWidth: 0, borderColor: nil)
            .setBackgroundColor(color: color(forColorPalette: .primary), for: .normal)
            .setBackgroundColor(color: color(forColorPalette: .gray_2), for: .disabled)
            .setBackgroundColor(color: color(forColorPalette: .primaryFocused), for: [.highlighted, .focused])
            .setTitleTextColor(color: color(forColorPalette: .white), for: .normal)
            .setTitleTextColor(color: color(forColorPalette: .gray_3), for: .disabled)
            .tintColor = .white
        
        button.showsTouchWhenHighlighted = false
        
        customizing?(button, self)
        
        return button
    }
    
    @discardableResult
    func configureSecondaryButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol)->Void)? = nil) -> UIButton {
        button.setupTitle(font: style.font)
            .setupLayer(cornerRadius: 4, borderWidth: 1, borderColor: color(forColorPalette: .primary).cgColor)
            .resetBackgrounds()
            .setTitleTextColor(color: color(forColorPalette: .primary), for: .normal)
            .tintColor = color(forColorPalette: .primary)
        
        button.showsTouchWhenHighlighted = false
        
        customizing?(button, self)
        
        return button
    }
    
    @discardableResult
    func configureTextOnlyButton(button: UIButton, withTitleStyle style: ThemeFontStyle, customizing: ((UIButton, ThemeProtocol)->Void)? = nil) -> UIButton {
        button.setupTitle(font: style.font)
            .setupLayer(cornerRadius: 0, borderWidth: 0, borderColor: nil)
            .resetBackgrounds()
            .setTitleTextColor(color: color(forColorPalette: .primary), for: .normal)
            .setTitleTextColor(color: color(forColorPalette: .gray_3), for: .disabled)
            .setTitleTextColor(color: color(forColorPalette: .gray_1), for: [.highlighted, .focused])
            .tintColor = color(forColorPalette: .primary)
        
        button.showsTouchWhenHighlighted = false
        
        customizing?(button, self)
        
        return button
    }
}

//TextField
extension ChristmasTheme {
    @discardableResult
    func configureBoxedTextField(textfield: UITextField, withTextStyle style: ThemeFontStyle, customizing: ((UITextField, ThemeProtocol)->Void)? = nil) -> UITextField {
        
        textfield.backgroundColor = color(forColorPalette: .gray_1)
        textfield.font = font(forStyle: style)
        textfield.textColor = color(forColorPalette: .black)
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textfield.frame.height))
        paddingView.backgroundColor = .clear
        textfield.leftView = paddingView
        textfield.leftViewMode = .always
        
        customizing?(textfield, self)
        return textfield
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

