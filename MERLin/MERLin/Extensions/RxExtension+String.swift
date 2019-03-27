//
//  RxExtension+String.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 26/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift

public extension ObservableType where Self.E == String {
    func isEmpty() -> Observable<Bool> {
        return map { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    func isNotEmpty() -> Observable<Bool> {
        return isEmpty().negate()
    }
}

public extension ObservableType where Self.E == String? {
    func isEmpty() -> Observable<Bool> {
        return map { $0?.trimmingCharacters(in: .whitespaces).isEmpty ?? true }
    }
    
    func isNotEmpty() -> Observable<Bool> {
        return isEmpty().negate()
    }
}

public extension SharedSequenceConvertibleType where Self.E == String {
    func isEmpty() -> SharedSequence<SharingStrategy, Bool> {
        return map { $0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    func isNotEmpty() -> SharedSequence<SharingStrategy, Bool> {
        return isEmpty().negate()
    }
}

public extension SharedSequenceConvertibleType where Self.E == String? {
    func isEmpty() -> SharedSequence<SharingStrategy, Bool> {
        return map { $0?.trimmingCharacters(in: .whitespaces).isEmpty ?? true }
    }
    
    func isNotEmpty() -> SharedSequence<SharingStrategy, Bool> {
        return isEmpty().negate()
    }
}
