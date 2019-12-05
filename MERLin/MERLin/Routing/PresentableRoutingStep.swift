//
//  PresentableRoutingStep.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation

public enum CloseButtonType: CustomStringConvertible {
    case none
    case title(String, onClose: (() -> Void)?)
    case image(UIImage, onClose: (() -> Void)?)
    
    public var description: String {
        switch self {
        case .none: return "no close button"
        case let .title(title, onClose):
            return "close button with title \"\(title)\"" + (onClose == nil ? "" : ", injecting custom action on close")
        case let .image(_, onClose):
            return "close button with image" + (onClose == nil ? "" : ", injecting custom action on close")
        }
    }
}

public enum RoutingStepPresentationMode: CustomStringConvertible {
    case none
    case embed(parentController: UIViewController, containerView: UIView)
    case push(withCloseButton: CloseButtonType)
    case modal(modalPresentationStyle: UIModalPresentationStyle)
    case modalWithNavigation(modalPresentationStyle: UIModalPresentationStyle, withCloseButton: CloseButtonType)
    
    public func override(withCloseButton closeButton: CloseButtonType) -> RoutingStepPresentationMode? {
        switch self {
        case .push: return .push(withCloseButton: closeButton)
        case let .modalWithNavigation(style, _): return .modalWithNavigation(modalPresentationStyle: style, withCloseButton: closeButton)
        case .embed, .modal, .none: return nil
        }
    }
    
    public var description: String {
        switch self {
        case .none: return "none"
        case .embed(let parentController, _):
            return "embed into \(parentController)"
        case let .push(closeButtonType):
            return "push with " + closeButtonType.description
        case let .modal(modalPresentationStyle):
            return "modal with style \(modalPresentationStyle)"
        case let .modalWithNavigation(modalPresentationStyle, closeButtonType):
            return "modal with style \(modalPresentationStyle) in navigation bar and " + closeButtonType.description
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
