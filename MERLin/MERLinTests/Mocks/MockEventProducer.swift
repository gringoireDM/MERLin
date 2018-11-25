//
//  MockEventProducer.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 25/11/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin
import RxSwift

class MockProducer<E: EventProtocol>: EventsProducer {
    var moduleName: String = "MockModule"
    var moduleSection: String = "ModuleTests"
    var moduleType: String = "test"
    
    var events: Observable<E> { return _events }
    var _events = PublishSubject<E>()
    
    let disposeBag: DisposeBag = DisposeBag()
}
