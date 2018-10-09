//
//  SwizzlerUtility.h
//  MERLin
//
//  Created by Giuseppe Lanza on 16/09/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SwizzlerUtility : NSObject

+(void) swizzle: (SEL) originalSelector withSelector: (SEL) swizzledSelector onClass: (Class)class;

@end

NS_ASSUME_NONNULL_END
