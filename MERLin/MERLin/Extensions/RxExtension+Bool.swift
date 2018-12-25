//
//  RxExtension+Bool.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 23/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift
import RxCocoa

public extension ObservableType where E == Bool {
    public func negate() -> Observable<E> {
        return self.map { !$0 }
    }
    
    public func takeTrue() -> Observable<E> {
        return self.filter { $0 }
    }
    
    public func takeFalse() -> Observable<E> {
        return self.filter { !$0 }
    }
}

public extension ObservableType where E == Bool? {
    public func negate(ifNil: Bool) -> Observable<Bool> {
        return self.map { $0 == nil ? ifNil : !($0!) }
    }
}

public extension SharedSequenceConvertibleType where E == Bool {
    public func negate() -> SharedSequence<SharingStrategy, E> {
        return self.map { !$0 }
    }
    
    public func takeTrue() -> SharedSequence<SharingStrategy, E> {
        return self.filter { $0 }
    }
    
    public func takeFalse() -> SharedSequence<SharingStrategy, E> {
        return self.filter { !$0 }
    }
}

public extension SharedSequenceConvertibleType where E == Bool? {
    public func negate(ifNil: Bool) -> SharedSequence<SharingStrategy, Bool>{
        return self.map { $0 == nil ? ifNil : !($0!) }
    }
}
