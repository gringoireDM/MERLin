//
//  ViewControllerEvent.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 20/06/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import RxSwift

public enum ViewControllerEvent: EventProtocol, Equatable, CaseIterable {
    case willAppear
    case appeared
    case willDisappear
    case disappeared
    
    fileprivate func toSelector() -> Selector {
        switch self {
        case .willAppear:
            return #selector(UIViewController.viewWillAppear(_:))
        case .appeared:
            return #selector(UIViewController.viewDidAppear(_:))
        case .willDisappear:
            return #selector(UIViewController.viewWillDisappear(_:))
        case .disappeared:
            return #selector(UIViewController.viewDidDisappear(_:))
        }
    }
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
        return Observable.merge(
            ViewControllerEvent.allCases.map { event in
                rx.sentMessage(event.toSelector()).map { _ in event }
            }
        )
    }
}
