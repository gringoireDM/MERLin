//
//  RxExtension.swift
//  Module
//
//  Created by Fabio Felici on 13/06/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift

public extension ObservableType {
    func toVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    func unwrap<T>() -> Observable<T> where E == T? {
        return filter { $0 != nil }.map { $0! }
    }
    
    func toRoutableObservable(throttleTime: TimeInterval = 0.5, scheduler: SchedulerType = MainScheduler.asyncInstance) -> Observable<E> {
        return throttle(throttleTime, latest: false, scheduler: MainScheduler.asyncInstance)
            .observeOn(scheduler)
    }
    
    func compactMap<R>(_ transform: @escaping (E) throws -> R?) -> Observable<R> {
        return map(transform).filter { $0 != nil }.map { $0! }
    }
    
    func compactFlatMapFirst<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O?) -> Observable<O.E> {
        return compactMap(selector)
            .flatMapFirst { $0 }
    }
    
    func compactFlatMap<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O?) -> Observable<O.E> {
        return compactMap(selector)
            .flatMap { $0 }
    }
    
    func compactFlatMapLatest<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O?) -> Observable<O.E> {
        return compactMap(selector)
            .flatMapLatest { $0 }
    }
}

public extension PrimitiveSequenceType where TraitType == MaybeTrait {
    func compactMap<R>(_ transform: @escaping (ElementType) throws -> R?) -> Maybe<R> {
        return map(transform).filter { $0 != nil }.map { $0! }
    }
}

public extension SharedSequenceConvertibleType {
    func compactMap<R>(_ transform: @escaping (E) -> R?) -> SharedSequence<SharingStrategy, R> {
        return map(transform).filter { $0 != nil }.map { $0! }
    }
}

public extension PrimitiveSequence where Trait == SingleTrait {
    func unwrapOrError<T>(_ error: Error) -> Single<T> where Element == T? {
        return filter { $0 != nil }.map { $0! }
            .ifEmpty(switchTo: Single.error(error))
    }
    
    func unwrapOrSwitch<T>(to single: Single<T>) -> Single<T> where Element == T? {
        return filter { $0 != nil }.map { $0! }
            .ifEmpty(switchTo: single)
    }
    
    func toVoid() -> Single<Void> {
        return map { _ in }
    }
    
    func compactFlatMapOrSwitch<R>(to single: Single<R>, _ selector: @escaping (ElementType) throws -> Single<R>?) -> Single<R> {
        return map(selector)
            .flatMap { $0 ?? single }
    }
    
    func compactFlatMapOrError<R>(_ error: Error, _ selector: @escaping (ElementType) throws -> Single<R>?) -> Single<R> {
        return map(selector)
            .flatMap { $0 ?? .error(error) }
    }
}

public extension SharedSequenceConvertibleType {
    func unwrap<T>() -> SharedSequence<SharingStrategy, T> where E == T? {
        return filter { $0 != nil }.map { $0! }
    }
}

public extension ObservableConvertibleType {
    func asDriver<O>(onErrorSendErrorTo errorHandler: O) -> Driver<E> where O: ObserverType, O.E == DisplayableError {
        return asDriver(onErrorRecover: { error in
            guard let _error = error as? DisplayableError else {
                print(error.localizedDescription)
                return .empty()
            }
            errorHandler.onNext(_error)
            return .empty()
        })
    }
    
    func asDriverIgnoreError() -> Driver<E> {
        return asDriver(onErrorRecover: { _ in .empty() })
    }
}
