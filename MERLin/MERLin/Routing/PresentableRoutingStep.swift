//
//  PresentableRoutingStep.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public enum RoutingStepPresentationMode {
    case embed //This is used for viewController embedded in other viewControllers. An example would be UITabBarController
    case push(withCloseButton: Bool, onClose: (()->())?)
    case modal
    case modalWithNavigation(withCloseButton: Bool, onClose: (()->())?)
    
    public func override(withCloseButton closeButton: Bool, onClose: (()->())?) -> RoutingStepPresentationMode? {
        switch self {
        case .push: return .push(withCloseButton: closeButton, onClose: onClose)
        case .modalWithNavigation: return .modalWithNavigation(withCloseButton: closeButton, onClose: onClose)
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
    public let modalPresentationStyle: UIModalPresentationStyle
    
    public init(withStep step: ModuleRoutingStep, presentationMode: RoutingStepPresentationMode, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        self.step = step
        self.presentationMode = presentationMode
        self.modalPresentationStyle = modalPresentationStyle
    }
}
