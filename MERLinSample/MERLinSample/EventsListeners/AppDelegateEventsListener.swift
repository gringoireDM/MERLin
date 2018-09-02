//
//  AppDelegateEventsListener.swift
//  TheBay
//
//  Created by Giuseppe Lanza on 27/07/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

import MERLin
import RxSwift
import CoreSpotlight

class AppDelegateEventsListener: RouteEventsListening {
    let router: Router
    
    init(withRouter router: Router) {
        self.router = router
    }

    func registerToEvents(for producer: EventsProducer) -> Bool {
        producer[event: AppDelegateEvent.didFinishLaunching].toVoid()
            .subscribe(onNext: {
                //Push notifications registration?
            }).disposed(by: producer.disposeBag)
        
        producer[event: AppDelegateEvent.willContinueUserActivity]
            .subscribe(onNext: { [weak self] _ in
                self?.router.showLoadingView()
            }).disposed(by: producer.disposeBag)
        
        Observable<String>.merge([
            producer[event: AppDelegateEvent.openURL].map { $0.absoluteString },
            producer[event: AppDelegateEvent.continueUserActivity]
                .map { $0.userInfo?[CSSearchableItemActivityIdentifier] as? String }
                .do(onNext: {[weak self] _ in self?.router.hideLoadingView()})
                .unwrap()
            ]).subscribe(onNext: {[weak self] in
                _ = self?.router.route(toDeeplink: $0)
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
