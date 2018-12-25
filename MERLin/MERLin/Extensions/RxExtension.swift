//
//  RxExtension.swift
//  Module
//
//  Created by Fabio Felici on 13/06/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxSwift
import RxCocoa

public extension ObservableType {

    public func toVoid() -> Observable<Void> {
        return self.map { _ in }
    }

    public func unwrap<T>() -> Observable<T> where E == T? {
        return self.filter { $0 != nil }.map { $0! }
    }
    
    public func toRoutableObservable() -> Observable<E> {
        return self.throttle(0.5, scheduler: MainScheduler.asyncInstance)
            .observeOn(MainScheduler.asyncInstance)
    }

    public func compactMap<R>(_ transform: @escaping (E) throws -> R?) -> Observable<R> {
        return map(transform).filter { $0 != nil }.map { $0! }
    }
}

public extension PrimitiveSequenceType where TraitType == MaybeTrait {
    public func compactMap<R>(_ transform: @escaping (ElementType) throws -> R?) -> Maybe<R> {
        return map(transform).filter { $0 != nil }.map { $0! }
    }
}

public extension SharedSequenceConvertibleType {
    public func compactMap<R>(_ transform: @escaping (E) -> R?) -> SharedSequence<SharingStrategy, R> {
        return map(transform).filter { $0 != nil }.map { $0! }
    }
}

public extension PrimitiveSequence where Trait == SingleTrait {
    public func unwrapOrError<T>(_ error: Error) -> Single<T> where Element == T? {
        return self.filter { $0 != nil }.map { $0! }
            .ifEmpty(switchTo: Single.error(error))
    }
    
    public func unwrapOrSwitch<T>(to single: Single<T>) -> Single<T> where Element == T? {
        return self.filter { $0 != nil }.map { $0! }
            .ifEmpty(switchTo: single)
    }
    
    public func toVoid() -> PrimitiveSequence<SingleTrait, Void> {
        return self.map { _ in }
    }
}

public extension SharedSequenceConvertibleType where Self.E == String {
    public func isNotEmpty() -> SharedSequence<SharingStrategy, Bool> {
        return self.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

public extension SharedSequenceConvertibleType where Self.E == String? {
    public func isNotEmpty() -> SharedSequence<SharingStrategy, Bool> {
        return self.map { $0?.trimmingCharacters(in: .whitespaces).isEmpty == false }
    }
}

public extension SharedSequenceConvertibleType {
    public func unwrap<T>() -> SharedSequence<SharingStrategy, T> where E == T? {
        return self.filter { $0 != nil }.map { $0! }
    }
}

public extension ObservableConvertibleType {
    func asDriver<O>(onErrorSendErrorTo errorHandler: O) -> Driver<E> where O: ObserverType, O.E == DisplayableError {
        return self.asDriver(onErrorRecover: { error in
            guard let _error = error as? DisplayableError else {
                print(error.localizedDescription)
                return .empty()
            }
            errorHandler.onNext(_error)
            return .empty()
        })
    }
    
    func asDriverIgnoreError() -> Driver<E> {
        return self.asDriver(onErrorRecover: { _ in .empty() })
    }
}
