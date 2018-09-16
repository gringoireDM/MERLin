//
//  ResettableAppearence.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 16/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
protocol ResettableUIAppearence: class {
    func tryCustomize(_ view: UIAppearance)
}

public class ResettableAppearence<T: UIAppearance>: ResettableUIAppearence {
    let appearence: (T) -> Void
    public init(applying appearence: @escaping (T) -> Void = { _ in }) {
        self.appearence = appearence
    }
    
    func customize(_ view: T) {
        appearence(view)
    }
    
    func tryCustomize(_ view: UIAppearance) {
        guard let v = view as? T else { return }
        customize(v)
    }
}

public class AppearanceProxy {
    static let resettableAppearances: NSMutableDictionary = NSMutableDictionary()
    static public func resetAppearences() {
        AppearanceProxy.resettableAppearances.removeAllObjects()
    }
}

public extension UIAppearance {
    static public var resettableAppearance: ResettableAppearence<Self>? {
        get { return AppearanceProxy.resettableAppearances["\(Self.self)"] as? ResettableAppearence<Self> }
        set { AppearanceProxy.resettableAppearances.setValue(newValue, forKey: "\(Self.self)") }
    }
}

@objc public extension UIView {
    @objc public func applyAppearence() {
        var cursor: AnyClass = type(of: self)
        var propagationTable: [AnyClass] = [cursor]
        while let superClass = cursor.superclass() {
            propagationTable.insert(superClass, at: 0)
            cursor = superClass
        }
        
        for type in propagationTable {
            guard let proxy = AppearanceProxy.resettableAppearances["\(type)"] as? ResettableUIAppearence else { continue }
            proxy.tryCustomize(self)
        }
    }
}
