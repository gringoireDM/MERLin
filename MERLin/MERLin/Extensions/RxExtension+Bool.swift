//
//  RxExtension+Bool.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 23/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift

public extension ObservableType where Element == Bool {
    func negate() -> Observable<Element> {
        return map { !$0 }
    }
    
    func takeTrue() -> Observable<Element> {
        return filter { $0 }
    }
    
    func takeFalse() -> Observable<Element> {
        return filter { !$0 }
    }
}

public extension ObservableType where Element == Bool? {
    func negate(ifNil: Bool) -> Observable<Bool> {
        return map { $0 == nil ? ifNil : !($0!) }
    }
}

public extension SharedSequenceConvertibleType where Element == Bool {
    func negate() -> SharedSequence<SharingStrategy, Element> {
        return map { !$0 }
    }
    
    func takeTrue() -> SharedSequence<SharingStrategy, Element> {
        return filter { $0 }
    }
    
    func takeFalse() -> SharedSequence<SharingStrategy, Element> {
        return filter { !$0 }
    }
}

public extension SharedSequenceConvertibleType where Element == Bool? {
    func negate(ifNil: Bool) -> SharedSequence<SharingStrategy, Bool> {
        return map { $0 == nil ? ifNil : !($0!) }
    }
}
