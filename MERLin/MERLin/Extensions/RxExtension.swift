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
    
    func unwrap<T>() -> Observable<T> where Element == T? {
        return filter { $0 != nil }.map { $0! }
    }
    
    func toRoutableObservable(throttleTime: DispatchTimeInterval = .milliseconds(500), scheduler: SchedulerType = MainScheduler.asyncInstance) -> Observable<Element> {
        return throttle(throttleTime, latest: false, scheduler: MainScheduler.asyncInstance)
            .observeOn(scheduler)
    }
    
    func compactFlatMapFirst<O: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> O?) -> Observable<O.Element> {
        return compactMap(selector)
            .flatMapFirst { $0 }
    }
    
    func compactFlatMap<O: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> O?) -> Observable<O.Element> {
        return compactMap(selector)
            .flatMap { $0 }
    }
    
    func compactFlatMapLatest<O: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> O?) -> Observable<O.Element> {
        return compactMap(selector)
            .flatMapLatest { $0 }
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
    
    func compactFlatMapOrSwitch<R>(to single: Single<R>, _ selector: @escaping (Element) throws -> Single<R>?) -> Single<R> {
        return map(selector)
            .flatMap { $0 ?? single }
    }
    
    func compactFlatMapOrError<R>(_ error: Error, _ selector: @escaping (Element) throws -> Single<R>?) -> Single<R> {
        return map(selector)
            .flatMap { $0 ?? .error(error) }
    }
}

public extension SharedSequenceConvertibleType {
    func unwrap<T>() -> SharedSequence<SharingStrategy, T> where Element == T? {
        return filter { $0 != nil }.map { $0! }
    }
}

public extension ObservableConvertibleType {
    func asDriverIgnoreError() -> Driver<Element> {
        return asDriver(onErrorRecover: { _ in .empty() })
    }
}
