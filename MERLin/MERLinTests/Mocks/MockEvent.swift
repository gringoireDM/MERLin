//
//  MockEvent.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 25/11/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import MERLin

enum MockEvent: EventProtocol, Equatable {
    case noPayload
    case anotherWithoutPayload
    case withAnonymousPayload(String)
    case withNamedPayload(payload: String)
}
