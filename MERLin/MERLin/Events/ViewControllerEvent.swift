//
//  ViewControllerEvent.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 20/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public enum ViewControllerEvent: EventProtocol, Equatable {
    case willAppear
    case appeared
    case willDisappear
    case disappeared
}

private var viewControllerEventHandle: UInt8 = 0
public extension UIViewController {
    var events: Observable<ViewControllerEvent> {
        guard let observable = objc_getAssociatedObject(self, &viewControllerEventHandle) as? Observable<ViewControllerEvent> else {
            let observable = makeVCEvents()
            objc_setAssociatedObject(self, &viewControllerEventHandle, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return observable
        }
        return observable
    }
    
    private func makeVCEvents() -> Observable<ViewControllerEvent> {
        let willAppearProducer = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in ViewControllerEvent.willAppear }
        
        let didAppearProducer = rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .map { _ in ViewControllerEvent.appeared }
        
        let willDisappearProducer = rx.sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
            .map { _ in ViewControllerEvent.willDisappear }
        
        let didDisappearProducer = rx.sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
            .map { _ in ViewControllerEvent.disappeared }
        
        return Observable.merge(
            willAppearProducer,
            didAppearProducer,
            willDisappearProducer,
            didDisappearProducer
        )
    }
}
