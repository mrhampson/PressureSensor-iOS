//
//  CPTMutablePlotRange+SwiftCompat.m
//  Mobile Medicine
//
//  Created by Marshall Hampson on 5/25/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

#import "CPTMutablePlotRange+SwiftCompat.h"

@implementation CPTMutablePlotRange (SwiftCompat)

- (void)setLengthFloat:(float)lengthFloat
{
    NSNumber *number = [NSNumber numberWithFloat:lengthFloat];
    [self setLength:[number decimalValue]];
}

- (void)setLocationFloat:(float)locationFloat
{
    NSNumber *number = [NSNumber numberWithFloat:locationFloat];
    [self setLocation:[number decimalValue]];
}

@end
