//
//  UIButton+Setters.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 20/04/18.
//  Copyright © 2018 Gilt. All rights reserved.
//

import UIKit

extension UIButton {
    func setupTitle(font: UIFont) -> UIButton {
        titleLabel?.font = font
        titleLabel?.textAlignment = .center
        return self
    }
    
    @discardableResult
    func setupLayer(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: CGColor?) -> UIButton {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor
        layer.masksToBounds = true
        
        return self
    }
    
    @discardableResult
    func resetBackgrounds() -> UIButton {
        setBackgroundImage(nil, for: [.normal, .disabled, .highlighted, .focused])
        return self
    }
    
    @discardableResult
    func setBackgroundColor(color: UIColor, for state: UIControlState) -> UIButton {
        setBackgroundImage(color.toImage(), for: state)
        return self
    }
    
    @discardableResult
    func setTitleTextColor(color: UIColor, for state: UIControlState) -> UIButton {
        setTitleColor(color, for: state)
        return self
    }
}
