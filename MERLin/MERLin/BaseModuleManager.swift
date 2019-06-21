//
//  BaseModuleManager.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import LNZWeakCollection

class ModuleWrapper {
    let module: AnyModule
    init(_ module: AnyModule) {
        self.module = module
    }
}

open class BaseModuleManager {
    private var eventsConsumers: [AnyEventsConsumer]
    
    @available(*, unavailable, renamed: "init(withEventsConsumers:)")
    public init(withEventsListeners eventsListeners: [AnyEventsConsumer] = []) {
        fatalError("unavailable. Use init(withEventsConsumers:)")
    }
    
    public init(withEventsConsumers consumers: [AnyEventsConsumer] = []) {
        eventsConsumers = consumers
    }
    
    // Hash consing design pattern.
    // The module will be retained by the viewController in this data structure,
    // but the reference to the view controller is weak. UIKit will retain the viewController
    // for as long as it stays on screen. When the viewController is dismissed, it will be
    // released, and when this happens, the module itself will be disposed as no one is retaining
    // it any longer.
    var moduleRetainer = WeakDictionary<UIViewController, ModuleWrapper>(withWeakRelation: .weakToStrong)
    
    @available(*, unavailable, renamed: "setupEventsConsumers(for:)")
    public func setupEventsListeners(for module: AnyModule) {}
    @available(*, unavailable, renamed: "setupEventsConsumers(for:)")
    public func setupEventsListeners(for producer: AnyEventsProducer) {}
    @available(*, unavailable, renamed: "addEventsConsumers")
    public func addEventsListeners(_ listeners: [AnyEventsConsumer]) {}
    
    public func setupEventsConsumers(for module: AnyModule) {
        guard let producer = module as? AnyEventsProducer else { return }
        setupEventsConsumers(for: producer)
    }
    
    public func setupEventsConsumers(for producer: AnyEventsProducer) {
        eventsConsumers.forEach { manager in
            manager.consumeEvents(from: producer)
        }
    }
    
    public func livingModules() -> [AnyModule] {
        return moduleRetainer.values.map { $0.module }
    }
    
    public func module(for viewController: UIViewController) -> AnyModule? {
        return moduleRetainer[viewController]?.module
    }
    
    public func addEventsConsumers(_ consumers: [AnyEventsConsumer]) {
        for consumer in consumers {
            eventsConsumers.append(consumer)
            
            moduleRetainer.values.forEach { (wrapper) in
                guard let producer = wrapper.module as? AnyEventsProducer else { return }
                consumer.consumeEvents(from: producer)
            }
        }
    }
}

extension BaseModuleManager: DeeplinkManaging {
    // MARK: - Deeplinks
    
    func deeplinkable(fromDeeplink deeplink: String) -> Deeplinkable.Type? {
        let responders = DeeplinkMatcher.typedAvailableDeeplinkHandlers.compactMap { (pair) -> Deeplinkable.Type? in
            let (key, value) = pair
            guard key.numberOfMatches(in: deeplink, range: NSRange(location: 0, length: deeplink.count)) > 0 else { return nil }
            return value as? Deeplinkable.Type
        }
        
        guard let type = responders.sorted(by: { (lhs, rhs) -> Bool in
            lhs.priority.rawValue > rhs.priority.rawValue
        }).first else { return nil }
        return type
    }
    
    public func viewControllerType(fromDeeplink deeplink: String) -> UIViewController.Type? {
        guard let type = deeplinkable(fromDeeplink: deeplink) else { return nil }
        return type.classForDeeplinkingViewController()
    }
    
    @discardableResult public func update(viewController: UIViewController, fromDeeplink deeplink: String, userInfo: [String: Any]?) -> Bool {
        guard let module = self.module(for: viewController) as? DeeplinkContextUpdatable else { return false }
        return module.updateContext(fromDeeplink: deeplink, userInfo: userInfo)
    }
    
    public func viewController(fromDeeplink deeplink: String, userInfo: [String: Any]?) -> UIViewController? {
        guard let type = deeplinkable(fromDeeplink: deeplink) else { return nil }
        guard let (module, controller) = type.module(fromDeeplink: deeplink, userInfo: userInfo) else { return nil }
        moduleRetainer.set(ModuleWrapper(module), forKey: controller)
        setupEventsConsumers(for: module)
        return controller
    }
    
    public func unmatchedDeeplinkRemainder(fromDeeplink deeplink: String) -> String? {
        guard let type = deeplinkable(fromDeeplink: deeplink) else { return nil }
        return type.remainderDeeplink(fromDeeplink: deeplink)
    }
}

extension BaseModuleManager: ViewControllerBuilding {
    public func setup<T: UIViewController>(_ moduleController: (module: AnyModule, controller: T)) -> T {
        moduleRetainer.set(ModuleWrapper(moduleController.module), forKey: moduleController.controller)
        setupEventsConsumers(for: moduleController.module)
        return moduleController.controller
    }
    
    public func viewController(for routingStep: PresentableRoutingStep) -> UIViewController {
        return setup(routingStep.step.make())
    }
}
