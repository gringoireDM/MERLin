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
}

public extension PrimitiveSequence where Trait == SingleTrait {
    public func subscribeWithDisplayableErrorHandling(on view: DisplayingError?, disposeBag: DisposeBag) {
        doDisplayableErrorHandling(on: view)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    public func doDisplayableErrorHandling(on view: DisplayingError?) -> PrimitiveSequence<SingleTrait, Element> {
        return observeOn(MainScheduler.asyncInstance)
            .do(onError: { [weak view] error in
                guard let error = error as? DisplayableError else { return }
                view?.displayError(error)
            })
    }
    
    public func flatMapWeak<T: AnyObject, R>(_ subj: T, orError error: Error, _ selector: @escaping (T, Element) -> PrimitiveSequence<SingleTrait, R>) -> PrimitiveSequence<SingleTrait, R> {
        return self.flatMap({ [weak subj] in
            guard let subj = subj else { return Single.error(error) }
            return selector(subj, $0)
        })
    }

    public func unwrapOrError<T>(_ error: Error) -> PrimitiveSequence<SingleTrait, T> where Element == T? {
        return self.filter { $0 != nil }.map { $0! }
            .ifEmpty(switchTo: Single.error(error))
    }
    
    public func unwrapOrSwitch<T>(to single: PrimitiveSequence<SingleTrait, T>) -> PrimitiveSequence<SingleTrait, T> where Element == T? {
        return self.filter { $0 != nil }.map { $0! }
            .ifEmpty(switchTo: single)
    }
    
    public func toVoid() -> PrimitiveSequence<SingleTrait, Void> {
        return self.map { _ in }
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == String {
    public func isNotEmpty() -> Driver<Bool> {
        return self.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == String? {
    public func isNotEmpty() -> Driver<Bool> {
        return self.map { $0?.trimmingCharacters(in: .whitespaces).isEmpty == false }
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    public func unwrap<T>() -> Driver<T> where E == T? {
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

public extension Reactive where Base: UICollectionViewFlowLayout {
    var itemSize: Binder<CGSize> {
        return Binder(base) {
            $0.itemSize = $1
        }
    }
    
    var headerReferenceSize: Binder<CGSize> {
        return Binder(base) {
            $0.headerReferenceSize = $1
        }
    }
    
    var footerReferenceSize: Binder<CGSize> {
        return Binder(base) {
            $0.footerReferenceSize = $1
        }
    }
}
