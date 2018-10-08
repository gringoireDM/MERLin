//
//  AppearanceRule.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 08/10/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import UIKit

public protocol AppearanceReversible {
    func apply()
    func revert()
}

public class PropertyAppearanceRule<T: UIAppearance, Value>: AppearanceReversible {
    var appearanceProxy: T
    let keypath: WritableKeyPath<T, Value>
    let value: Value
    var originalValue: Value?
    
    public init(proxy: T, keypath: WritableKeyPath<T, Value>, value: Value) {
        appearanceProxy = proxy
        self.keypath = keypath
        self.value = value
    }
    
    public func apply() {
        originalValue = appearanceProxy[keyPath: keypath]
        appearanceProxy[keyPath: keypath] = value
    }
    
    public func revert() {
        guard let originalValue = originalValue else { return }
        appearanceProxy[keyPath: keypath] = originalValue
    }
}

public class SelectorAppearanceRule<T: UIAppearance, Value>: AppearanceReversible {
    var appearanceProxy: T
    let value: Value
    var originalValue: Value?
    
    let getter: (T)->Value
    let setter: (T, Value)->Void
    
    public init(proxy: T, get: @escaping (T)->Value, set: @escaping (T, Value)->Void, value: Value) {
        appearanceProxy = proxy
        self.value = value
        self.getter = get
        setter = set
    }
    
    public func apply() {
        originalValue = getter(appearanceProxy)
        setter(appearanceProxy, value)
    }
    
    public func revert() {
        guard let originalValue = originalValue else { return }
        setter(appearanceProxy, originalValue)
    }
}

public extension Array where Element == AppearanceReversible {
    public func apply() {
        forEach { $0.apply() }
    }
    
    public func revert() {
        forEach { $0.revert() }
    }
}
