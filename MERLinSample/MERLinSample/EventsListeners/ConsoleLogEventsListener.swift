//
//  ConsoleLogEventsListener.swift
//  Restaurants
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import MERLin

class ConsoleLogEventsListener: AnyEventsListener {
    @discardableResult func listenEvents(from producer: AnyEventsProducer) -> Bool {
        let pageName = "\(type(of: producer))"
        producer.anyEvents.map { "[\(pageName)] \($0)" }
            .subscribe(onNext: { print($0) })
            .disposed(by: producer.disposeBag)
        
        return true
    }
}
