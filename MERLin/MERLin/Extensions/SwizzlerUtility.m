//
//  SwizzlerUtility.m
//  MERLin
//
//  Created by Giuseppe Lanza on 16/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

#import "SwizzlerUtility.h"
#import <Objc/runtime.h>

@implementation SwizzlerUtility

+(void)swizzle:(SEL)originalSelector withSelector:(SEL)swizzledSelector onClass:(Class)class {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    //We try to add the implementation of the swizzled method in the original selector.
    //This operation will succede only if the subclass did not override the original selector.
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        //If we succede, we need to replace the swizzled method implementation with the original
        //method implementation. In short, this case fallsback in a runtime override.
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        //In case of failure, a method override the original method. Then, a simple exchange of
        //implementations is enough.
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
