//
//  ConsoleLogEventsListener.swift
//  Restaurants
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import MERLin

class ConsoleLogEventsListener: AnyEventsListening {
    @discardableResult func registerToEvents(for producer: AnyEventsProducer) -> Bool {
        producer.anyEvents.map { [weak producer] in "[\(producer?.moduleName ?? "Deallocated producer")] \($0)" }
            .subscribe(onNext: { print($0) })
            .disposed(by: producer.disposeBag)
        
        return true
    }
}
