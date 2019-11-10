//
//  BaseModuleManager.swift
//  Module
//
//  Created by Giuseppe Lanza on 14/08/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import Foundation
import LNZWeakCollection
import os.log

class ModuleWrapper: Hashable {
    static func == (lhs: ModuleWrapper, rhs: ModuleWrapper) -> Bool {
        return lhs.module === rhs.module
    }
    
    let module: AnyModule
    init(_ module: AnyModule) {
        self.module = module
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(module.hash)
    }
}

open class BaseModuleManager {
    private var eventsListeners: [AnyEventsListener]
    
    public init(withEventsListeners eventsListeners: [AnyEventsListener] = []) {
        self.eventsListeners = eventsListeners
    }
    
    // Hash consing design pattern.
    // The module will be retained by the viewController in this data structure,
    // but the reference to the view controller is weak. UIKit will retain the viewController
    // for as long as it stays on screen. When the viewController is dismissed, it will be
    // released, and when this happens, the module itself will be disposed as no one is retaining
    // it any longer.
    var moduleRetainer = WeakDictionary<UIViewController, ModuleWrapper>(withWeakRelation: .weakToStrong)
    
    public func setupEventsListeners(for module: AnyModule) {
        guard let producer = module as? AnyEventsProducer else { return }
        setupEventsListeners(for: producer)
    }
    
    public func setupEventsListeners(for producer: AnyEventsProducer) {
        #if DEBUG
            producer.anyEvents.map { $0.label }
                .subscribe(onNext: { [weak producer] event in
                    guard let producer = producer else { return }
                    os_log("✉️ %@ emitted a new event: %@", log: .producer, type: .debug, String(describing: type(of: producer)), event)
                }).disposed(by: producer.disposeBag)
        #endif
        eventsListeners.forEach { listener in
            guard listener.listenEvents(from: producer) else { return }
            os_log("👂 Listener %@ accepted events from %@", log: .moduleManager, type: .debug,
                   String(describing: type(of: listener)), String(describing: type(of: producer)))
        }
    }
    
    public func livingModules() -> [AnyModule] {
        return Set(moduleRetainer.values.map { ModuleWrapper($0.module) })
            .map { $0.module }
    }
    
    public func module(for viewController: UIViewController) -> AnyModule? {
        return moduleRetainer[viewController]?.module
    }
    
    public func addEventsListeners(_ listeners: [AnyEventsListener]) {
        for listener in listeners {
            eventsListeners.append(listener)
            os_log("👂 Added new events listener %@", log: .moduleManager, type: .debug, String(describing: type(of: listener)))
            
            moduleRetainer.values.forEach { (wrapper) in
                guard let producer = wrapper.module as? AnyEventsProducer else { return }
                guard listener.listenEvents(from: producer) else { return }
                os_log("👂 New listener %@ accepted events from %@", log: .moduleManager,
                       String(describing: type(of: listener)), String(describing: type(of: producer)))
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
        
        guard let responderType = responders.sorted(by: { (lhs, rhs) -> Bool in
            lhs.priority.rawValue > rhs.priority.rawValue
        }).first else {
            os_log("🔗 Could not find any deeplink responder for deeplink %@", log: .moduleManager, type: .debug, deeplink)
            return nil
        }
        
        os_log("🔗 Found deeplink responder for deeplink (%@): %@", log: .moduleManager, type: .debug,
               deeplink, String(describing: type(of: responderType)))
        
        return responderType
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
        setupEventsListeners(for: module)
        return controller
    }
    
    public func unmatchedDeeplinkRemainder(fromDeeplink deeplink: String) -> String? {
        guard let type = deeplinkable(fromDeeplink: deeplink) else { return nil }
        return type.remainderDeeplink(fromDeeplink: deeplink)
    }
}

extension BaseModuleManager: ViewControllerBuilding {
    public func setup<T: UIViewController>(_ moduleController: (module: AnyModule, controller: T)) -> T {
        let (module, controller) = moduleController
        
        os_log("🖼 Built new module of type %@ with its viewController: %@", log: .moduleManager, type: .debug,
               String(describing: type(of: module)), String(describing: type(of: controller)))

        module.newViewControllers.skip(1)
            .observeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
            .subscribe(onNext: { [weak self, weak module] newVC in
                guard let module = module else { return }
                self?.moduleRetainer.set(ModuleWrapper(module), forKey: newVC)
            }).disposed(by: module.disposeBag)
        
        moduleRetainer.set(ModuleWrapper(module), forKey: controller)
        
        setupEventsListeners(for: module)
        
        return controller
    }
    
    public func viewController(for routingStep: PresentableRoutingStep) -> UIViewController {
        os_log("🖼 Building module for step: %@", log: .moduleManager, type: .info, routingStep.description)
        return setup(routingStep.step.make())
    }
}
