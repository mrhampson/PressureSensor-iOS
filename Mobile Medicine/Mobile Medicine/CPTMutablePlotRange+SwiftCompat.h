//
//  CPTMutablePlotRange+SwiftCompat.h
//  Mobile Medicine
//
//  Created by Marshall Hampson on 5/25/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTMutablePlotRange.h"

@interface CPTMutablePlotRange (SwiftCompat)

- (void)setLengthFloat:(float)lengthFloat;
- (void)setLocationFloat:(float)locationFloat;

@end
