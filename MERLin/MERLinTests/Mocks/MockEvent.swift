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

enum MockBlockEvent: EventProtocol, Equatable {
    case withBlock(block: (String) -> Void)
    case withUnnamedBlock((String) -> Void)
    case withMixBlock(String, block: (String) -> Void)
    case withNamedMixBlock(name: String, block: (String) -> Void)
    case withUnnamedMixBlock(String, (String) -> Void)
    
    static func == (lhs: MockBlockEvent, rhs: MockBlockEvent) -> Bool {
        switch (lhs, rhs) {
        case (.withBlock, .withBlock): return true
        case (.withUnnamedBlock, .withUnnamedBlock): return true
        case let (.withMixBlock(lhsName, _), .withMixBlock(rhsName, _)): return lhsName == rhsName
        case let (.withNamedMixBlock(lhsName, _), .withNamedMixBlock(rhsName, _)): return lhsName == rhsName
        case let (.withUnnamedMixBlock(lhsName, _), .withUnnamedMixBlock(rhsName, _)): return lhsName == rhsName
        default: return false
        }
    }
}
