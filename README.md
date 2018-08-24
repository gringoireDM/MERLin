![HBC Digital](https://raw.githubusercontent.com/gilt/Cleanroom/master/Assets/hbc-digital-logo.png)

<p align="center">
<img src="./MerlinLogo.png" alt="MERLin"/>
</p>

# Index

- [Module](#module)
- [Build Context](#build-contexts)
- [Events Listeners](#events-listeners)
- [Module Manager](#the-module-manager)
- [Routing](#routing)

# TheBay-iOS

The Bay app uses an Event Based architectural style. Each module expose a series of events that can happen within the module itself and multiple observers can subscribe to these events.
The messaging design pattern used for this events management is Publish–subscribe and the particular implementation is powered by `RxSwift`.

# Module

A module in the app is a framework embedded via app target. It can be an EventsProducer and in this case it is responsible for capturing user interactions and exposing an Events Descriptor to events listeners. 

An Events Descriptor is a list of events that can be triggered by a module. Modules use `RxSwift` to define and describe events.

When creating a module it is necessary to create a class that acts as an interface with the outside world. Usually this class has the same name as the module framework. This class must be of type `Module` (or a subclass of Module) and it should expose a personalized reactive layer.

The module class is the entry point of a module and is the correct place to perform configuration and dependency injection of the components in the module. For example, if you are working with an MVVM architecture the module class is the correct place to set up connections between the view and the view-model, inject dependencies for data interaction, etc.

A module can expose interfaces for objects it uses and manipulates, but will never expose the real object implementation in respect to the SOLID principles. In fact it should be useable as a black box without knowing which is its particular architectural implementation. 

A module is not always exposing a single ViewController. Each module might even have an internal navigation system to fulfil the purpose of the module. For example the ProductArrayModule has an internal navigation to fulfil the change of sorting options and filtering. This kind of approach should be used in case a particular viewController will never be re-used or needed in other contexts; the perfect example is the filter page for product array.

## Build contexts

To build a module, a build context is required. A Build context represents the initial conditions that triggered the module to be built, for example a PDP Module will need the id of the product it must show, as well as the Product Array module will need the id of the category it has to display. It will also contain a disambiguation variable declaring which routing flow caused the creation of the module.

# Events Listeners

An events listener is a main target feature that is written to react to module events (or a specific set of a module's events). Each events listener should fullfil the single responsibility principle.

Currently we have events listeners for each analytics provider, for each routing app flow (atm main and checkout), for CoreSpotlight indexing and for NSUserActivity logging.

Events listeners uses `RxSwift` to react to events dispatched by an events producer and combine them as needed in the particular event handling business logic.

In theory there is no limit to the amount of events listeners that can be written to fullfil any specific reaction to events. It is in fact possible to have analytics events listeners for each module (highly recommended) and it is possible to have events listeners for specific purposes. (CoreSpotlight, NSUserActivity, Analytics {Provider a, b, c}, Main flow routing, Checkout flow routing, AppDelegate events, and so on...)

# The Module Manager

The module manager will take care of building modules and tracking living ones, keeping them alive for as long as the viewController associated with them is used.

The modules will be kept alive using the Flyweight (hash consing) design pattern. A Weak dictionary will have a weak reference to the viewController associated to the module as key and a strong reference to the module itself as value. When the view controller becomes nil because it is no longer retained by UIKit, the module will be deallocated as well.

The Flyweight design pattern is implemented using [`LNZWeakCollection`](https://github.com/gringoireDM/LNZWeakCollection) to have Dictionaries with weak keys and strong values (or vice versa).

`NSHashTable` was used at the beginning, but the release of weak references is done by this object only when the data structure requires resizing. The module was staying alive for longer than it was needed. `LNZWeakCollection` kills the dead reference almost immediately (exactly at the next usage of the instance of the data structure).

The module manager cannot build modules. This duty is left to a ModuleMaking object. in this particular implementation it's the responsibility of the `ModuleRoutingStep`.

When a new module is created from a `ModuleRoutingStep` (or from a Deeplink) the module manager will direct all registered events listeners to subscribe to interesting events.

# Routing

Routing in this architectural model is a plug-in implemented through events listener. Whenever an event can be transformed as a routing event the Routing events listener interested in that particular event will be listening to transform it into a routing step. Each `RoutingEventsListener` has a reference to a Router that then will be able to transform the RoutingStep into an actual UI action (push, present and so on).

Routers are the only objects that have a strong connection with the module manager so that they can ask it for a viewController to perform a specific routing step.

Routers have references to the module manager, but this still happens through abstraction; in fact Routers use ViewControllerFactory. (Routers do not know about the existence of modules)

## Routing step

We must not forget that routing is something that cannot be abstracted from the fact that a page exists. On import of a specific module, the existence of this module is exposed to the rest of the main target via an extension of `ModuleRoutingStep` in which a static function will be responsible for building a `ModuleRoutingStep` instance with the right module making object.
