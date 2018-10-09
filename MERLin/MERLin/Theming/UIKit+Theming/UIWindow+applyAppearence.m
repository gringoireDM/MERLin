//
//  UIWindow+applyAppearence.m
//  MERLin
//
//  Created by Giuseppe Lanza on 16/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

#import "UIWindow+applyAppearence.h"
#import <MERLin/MERLin-Swift.h>
#import "SwizzlerUtility.h"

@implementation UIWindow (applyAppearence)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(makeKeyWindow);
        SEL swizzledSelector = @selector(swizzled_makeKeyWindow);
        
        [SwizzlerUtility swizzle:originalSelector withSelector:swizzledSelector onClass:class];
    });

}

-(void) swizzled_makeKeyWindow {
    [self swizzled_makeKeyWindow];
    [self applyDefaultThemeWithOverrideLocal:NO];
}

@end
