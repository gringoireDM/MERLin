//
//  EventsTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 09/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import MERLin

enum MockEvent: EventProtocol {
    case noPayload
    case withAnonymousPayload(String)
    case withNamedPayload(payload: String)
    
    var payload: String? {
        switch self {
        case .noPayload: return nil
        case .withAnonymousPayload(let value): return value
        case .withNamedPayload(let value): return value
        }
    }
}

class EventsTests: XCTestCase {
    
}
