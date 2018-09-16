//
//  UIView+ResettableAppearance.m
//  MERLin
//
//  Created by Giuseppe Lanza on 16/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

#import "UIView+ResettableAppearance.h"
#import <MERLin/MERLin-Swift.h>
#import "SwizzlerUtility.h"

@implementation UIView (ResettableAppearance)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(didMoveToWindow);
        SEL swizzledSelector = @selector(swizzled_didMoveToWindow);
        
        [SwizzlerUtility swizzle:originalSelector withSelector:swizzledSelector onClass:class];
    });
}

-(void) swizzled_didMoveToWindow {
    //At this point, the method should be swizzled, so calling swizzled_didMoveToWindow is actually
    //calling the original method.
    [self swizzled_didMoveToWindow];
    [self applyAppearence];
}

@end
