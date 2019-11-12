//
//  PresentableRoutingStep.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public enum RoutingStepPresentationMode: CustomStringConvertible {
    case none
    case embed(parentController: UIViewController, containerView: UIView)
    case push(withCloseButton: Bool, onClose: (() -> Void)?)
    case modal(modalPresentationStyle: UIModalPresentationStyle)
    case modalWithNavigation(modalPresentationStyle: UIModalPresentationStyle, withCloseButton: Bool, onClose: (() -> Void)?)
    
    public func override(withCloseButton closeButton: Bool, onClose: (() -> Void)?) -> RoutingStepPresentationMode? {
        switch self {
        case .push: return .push(withCloseButton: closeButton, onClose: onClose)
        case let .modalWithNavigation(style, _, _): return .modalWithNavigation(modalPresentationStyle: style, withCloseButton: closeButton, onClose: onClose)
        case .embed, .modal, .none: return nil
        }
    }
    
    public var description: String {
        switch self {
        case .none: return "none"
        case .embed(let parentController, _):
            return "embed into \(parentController)"
        case let .push(withCloseButton, onClose):
            return "push" +
                (withCloseButton ?
                    " forcing close button" + (onClose == nil ? "" : ", injecting custom action on close") :
                    "")
        case let .modal(modalPresentationStyle):
            return "modal with style \(modalPresentationStyle)"
        case let .modalWithNavigation(modalPresentationStyle, withCloseButton, onClose):
            return "modal with style \(modalPresentationStyle) in navigation bar" +
                (withCloseButton ?
                    " forcing close button" + (onClose == nil ? "" : ", injecting custom action on close") :
                    "")
        }
    }
}

public struct ModuleRoutingStep: CustomStringConvertible {
    private var wrappedMaker: AnyModuleContextProtocol
    public var routingContext: String { return wrappedMaker.routingContext }
    
    public var make: () -> (AnyModule, UIViewController) {
        return wrappedMaker.make
    }
    
    public init(withMaker maker: AnyModuleContextProtocol) {
        wrappedMaker = maker
    }
    
    public var description: String {
        return "Context: \(wrappedMaker); Flow: \(routingContext)"
    }
}

public struct PresentableRoutingStep: CustomStringConvertible {
    public let step: ModuleRoutingStep
    public let presentationMode: RoutingStepPresentationMode
    public let animated: Bool
    
    /// This closure will be invoked right before the viewController associated to the step will be pushed/presented.
    /// This closure should be used for further customization of the presentation style like custom animators.
    ///
    /// The viewController passed to this closure will be the ViewController after the presentation mode customization
    /// but before this is associated to a container, meaning that it will not have any parent, not a navigationController
    /// or a tabBarController.
    public let beforePresenting: ((UIViewController) -> Void)?
    
    public init(withStep step: ModuleRoutingStep, presentationMode: RoutingStepPresentationMode, animated: Bool = true, beforePresenting: ((UIViewController) -> Void)? = nil) {
        self.step = step
        self.presentationMode = presentationMode
        self.animated = animated
        self.beforePresenting = beforePresenting
    }
    
    public var description: String {
        return "\(step) -|- Presentation mode: \(presentationMode) -|- Animated: \(animated)"
    }
}
