//
//  PresentableRoutingStep.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public enum RoutingStepPresentationMode {
    case embed(parentController: UIViewController, containerView: UIView)
    case push(withCloseButton: Bool, onClose: (()->())?)
    case modal(modalPresentationStyle: UIModalPresentationStyle)
    case modalWithNavigation(modalPresentationStyle: UIModalPresentationStyle, withCloseButton: Bool, onClose: (()->())?)

    public func override(withCloseButton closeButton: Bool, onClose: (()->())?) -> RoutingStepPresentationMode? {
        switch self {
        case .push: return .push(withCloseButton: closeButton, onClose: onClose)
        case let .modalWithNavigation(style, _, _): return .modalWithNavigation(modalPresentationStyle: style, withCloseButton: closeButton, onClose: onClose)
        case .embed, .modal: return nil
        }
    }
}

public struct ModuleRoutingStep {
    private var wrappedMaker: ModuleMaking
    public var routingContext: String { return wrappedMaker.routingContext }
    
    public var make: () -> (AnyModule, UIViewController) {
        return wrappedMaker.make
    }
    
    public init(withMaker maker: ModuleMaking) {
        wrappedMaker = maker
    }
}

public struct PresentableRoutingStep {
    public let step: ModuleRoutingStep
    public let presentationMode: RoutingStepPresentationMode
    
    public init(withStep step: ModuleRoutingStep, presentationMode: RoutingStepPresentationMode) {
        self.step = step
        self.presentationMode = presentationMode
    }
}
