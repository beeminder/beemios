//
//  GradientViews.m
//  Beeminder
//
//  Created by Andy Brett on 8/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GradientViews.h"

@implementation GradientViews

+(void)addGradient:(UIView *)view withColor:(UIColor *)color startAtTop:(BOOL)startAtTop cornerRadius:(CGFloat)cornerRadius borderColor:(UIColor *)borderColor
{
    // Add Border
    CALayer *layer = view.layer;
    layer.cornerRadius = cornerRadius;
    layer.masksToBounds = YES;
    if (borderColor) {
        layer.borderWidth = 1.0f;
        layer.borderColor = borderColor.CGColor;
    }

    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];

    const CGFloat *components = CGColorGetComponents([color CGColor]);
    int numComponents = CGColorGetNumberOfComponents([color CGColor]);

    shineLayer.frame = layer.bounds;
    
    if (numComponents == 4) {
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        CGFloat alpha = components[3];
        shineLayer.colors = [NSArray arrayWithObjects:
                             (id)[UIColor colorWithRed:red green:green blue:blue alpha:alpha + 0.4].CGColor,
                             (id)[UIColor colorWithRed:red green:green blue:blue alpha:alpha - 0.4].CGColor,
                             nil];
    }
    else if(numComponents == 2) {
        CGFloat white = components[0];
        CGFloat alpha = components[1];
        shineLayer.colors = [NSArray arrayWithObjects:
                             (id)[UIColor colorWithWhite:white alpha:alpha + 0.4].CGColor,
                             (id)[UIColor colorWithWhite:white alpha:alpha - 0.4].CGColor,
                             nil];
    }
    
    if (!startAtTop) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:[shineLayer.colors count]];
        NSEnumerator *enumerator = [shineLayer.colors reverseObjectEnumerator];
        for (id element in enumerator) {
            [array addObject:element];
        }
        shineLayer.colors = [NSArray arrayWithArray:array];
    }
    
    if ([view isKindOfClass:[UIButton class]]) {
        [layer insertSublayer:shineLayer atIndex:2];
    }
    else {
        [layer insertSublayer:shineLayer atIndex:0];
    }

}

@end
