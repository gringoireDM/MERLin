//
//  AppDelegateEventsListener.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 27/07/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

import CoreSpotlight
import MERLin
import RxSwift

class AppDelegateEventsListener: EventsConsumer {
    let router: Router
    
    init(withRouter router: Router) {
        self.router = router
    }
    
    func consumeEvents(from producer: AnyEventsProducer, events: Observable<AppDelegateEvent>) -> Bool {
        producer[event: AppDelegateEvent.didFinishLaunching].toVoid()
            .subscribe(onNext: {
                // Push notifications registration?
            }).disposed(by: producer.disposeBag)
        
        producer[event: AppDelegateEvent.willContinueUserActivity]
            .subscribe(onNext: { [weak self] _ in
                self?.router.showLoadingView()
            }).disposed(by: producer.disposeBag)
        
        Observable<String>.merge([
            producer[event: AppDelegateEvent.openURL].map { $0.absoluteString },
            producer[event: AppDelegateEvent.continueUserActivity]
                .do(onNext: { [weak self] _ in self?.router.hideLoadingView() })
                .compactMap { $0.userInfo?[CSSearchableItemActivityIdentifier] as? String }
        ]).subscribe(onNext: { [weak self] in
            _ = self?.router.route(toDeeplink: $0, userInfo: nil)
        }).disposed(by: producer.disposeBag)
        
        producer[event: AppDelegateEvent.failedToContinueUserActivity]
            .subscribe(onNext: { [weak self] _ in
                self?.router.hideLoadingView()
            }).disposed(by: producer.disposeBag)
        
        producer[event: AppDelegateEvent.didUseShortcut]
            .subscribe(onNext: { [weak self] in
                self?.router.handleShortcutItem($0)
            }).disposed(by: producer.disposeBag)
        
        return true
    }
}
