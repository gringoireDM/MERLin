//
//  RxExtension+Bool.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 23/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift

public extension ObservableType where E == Bool {
    public func negate() -> Observable<E> {
        return map { !$0 }
    }
    
    public func takeTrue() -> Observable<E> {
        return filter { $0 }
    }
    
    public func takeFalse() -> Observable<E> {
        return filter { !$0 }
    }
}

public extension ObservableType where E == Bool? {
    public func negate(ifNil: Bool) -> Observable<Bool> {
        return map { $0 == nil ? ifNil : !($0!) }
    }
}

public extension SharedSequenceConvertibleType where E == Bool {
    public func negate() -> SharedSequence<SharingStrategy, E> {
        return map { !$0 }
    }
    
    public func takeTrue() -> SharedSequence<SharingStrategy, E> {
        return filter { $0 }
    }
    
    public func takeFalse() -> SharedSequence<SharingStrategy, E> {
        return filter { !$0 }
    }
}

public extension SharedSequenceConvertibleType where E == Bool? {
    public func negate(ifNil: Bool) -> SharedSequence<SharingStrategy, Bool> {
        return map { $0 == nil ? ifNil : !($0!) }
    }
}
