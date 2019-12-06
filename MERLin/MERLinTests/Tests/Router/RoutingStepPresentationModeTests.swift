//
//  RoutingStepPresentationModeTests.swift
//  MERLinTests
//
//  Created by Giuseppe Lanza on 28/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import XCTest

@testable import MERLin

class RoutingStepPresentationModeTests: XCTestCase {
    func testItCanOverridePushWithCloseButton() {
        var value = 1
        let mode = RoutingStepPresentationMode.push(withCloseButton: .none)
        guard let newMode = mode.override(withCloseButton: .title("Close", onClose: { value += 1 })),
            case let .push(closeButton) = newMode else {
            XCTFail("newMode is not push")
            return
        }
        guard case let .title(_, onClose) = closeButton else {
            XCTFail("button is not title")
            return
        }
        
        onClose?()
        XCTAssert(value == 2)
    }
    
    func testItCanOverrideModalWithNavigation() {
        var value = 1
        let mode = RoutingStepPresentationMode.modalWithNavigation(modalPresentationStyle: .currentContext, withCloseButton: .none)
        guard let newMode = mode.override(withCloseButton: .title("Close", onClose: { value += 1 })),
            case let .modalWithNavigation(style, closeButton) = newMode else {
            XCTFail("newMode is not modal with navigation")
            return
        }
        XCTAssertEqual(style, .currentContext)
        
        guard case let .title(_, onClose) = closeButton else {
            XCTFail("button is not title")
            return
        }
        onClose?()
        XCTAssertEqual(value, 2)
    }
    
    func testItCantOverrideModalEmbedAndNone() {
        let modes = [
            RoutingStepPresentationMode.none,
            .embed(parentController: UIViewController(), containerView: UIView()),
            .modal(modalPresentationStyle: .currentContext)
        ]
        
        for mode in modes {
            XCTAssertNil(mode.override(withCloseButton: CloseButtonType.title("Close", onClose: nil)))
        }
    }
}
