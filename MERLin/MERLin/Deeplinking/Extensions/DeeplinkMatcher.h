//
//  Module+Deeplink.h
//  TheBay
//
//  Created by Giuseppe Lanza on 19/02/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
Make a Module subclass conforming this protocol to make that module
automatically deeplinkable. The principle behind this automatic implementation
is that to make a module deeplinkable should be simple enough and should not
require additional code, and the list of available deeplinkable modules should
reflect (and expand) accordingly to the modules built in the app.
The removal or the addition of a Deeplinkable module **must** not affect the
rest of the app. The list of available deeplinkable modules is built in runtime
so that no maintenance is needed once the deeplink engin is built to be agnostic
respect the modules that are going to be deeplinked. In this way, also god
deeplink managers are avoided, and nobody knows how to build a module out of a
deeplink, if not the module itself.
*/
@protocol DeeplinkResponder

/// The schemas that can be used for the deeplink. They will be used in the regex
/// chained as **or** matches. `(schema1|schema2):\/\/....`
@property (class, nonatomic, retain) NSArray<NSString *> *deeplinkSchemaNames;

/// The regex to parse the deeplink and decide if the module implementing Deeplinkable
/// can handle the deeplink.
+ (NSArray<NSRegularExpression *> *) deeplinkRegexes;

@end

@interface DeeplinkMatcher : NSObject

+ (NSMutableDictionary *) availableDeeplinkHandlers;

@end

