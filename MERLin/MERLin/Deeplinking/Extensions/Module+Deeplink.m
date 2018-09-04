//
//  Module+Deeplink.m
//  TheBay
//
//  Created by Giuseppe Lanza on 19/02/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

#import <MERLin/Module+Deeplink.h>
#import <MERLin/MERLin-Swift.h>

@implementation Module (Deeplink)

/*!This method will fetch all the subclass of Module
 @return NSArray<Class> *: An array of classes that are subclassing Module
 */
+(NSArray<Class> *) potentialDeeplinkResponders {
    Class * classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    
    NSMutableArray<Class> *result = [NSMutableArray new];
    if (numClasses > 0 ) {
        classes = (Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        
        for (int i = 0; i < numClasses; ++i){
            Class class = classes[i];

            if (class_getClassMethod(class, NSSelectorFromString(@"deeplinkRegexes"))) {
                [result addObject: class];
            }
        }
        
        free(classes);
    }
    
    return result;
}
    
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //Searching in all the `Module` subclasses for deeplinkable modules and registering
        //them to available deeplinking path.
        for (Class class in [self potentialDeeplinkResponders]) {
            [self registerAsDeeplinking:class];
        }
    });
}

+(void) registerAsDeeplinking: (Class) class {
    //Each deeplinkable class has at least one regular expression to match the deeplink.
    //The deeplink matcher will be fed with the regular expression from each deeplinkable module
    //in runtime in a dictionary of type regex: ModuleClass. This way the deeplink engine will know,
    //by matching the regular expression in key which is the module that can handle that particular
    //deeplink. Similar approach is used in mParticle foreach provider implementation.
    if([class conformsToProtocol: @protocol(DeeplinkResponder)]) {
        NSArray<NSRegularExpression *> *regexes = [(id<DeeplinkResponder>) class deeplinkRegexes];
        if (regexes) {
            for(NSRegularExpression *regex in regexes) {
                DeeplinkMatcher.availableDeeplinkHandlers[regex] = class;
            }
        }
    }
}

@end
