//
//  FloatToDecimal.m
//  Mobile Medicine
//
//  Created by Marshall Hampson on 5/27/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

#import "FloatToDecimal.h"

@implementation FloatToDecimal : NSObject

+ (NSDecimal) Convert:(float)floatNumber
{
    NSNumber *number = [NSNumber numberWithFloat:floatNumber];
    return [number decimalValue];
}

@end