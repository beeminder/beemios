//
//  GradientViews.m
//  Beeminder
//
//  Created by Andy Brett on 8/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GradientViews.h"

@implementation GradientViews

+(void)addGradient:(UIView *)view withColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius borderColor:(UIColor *)borderColor
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
                             (id)[UIColor colorWithRed:red green:green blue:blue alpha:0.4f].CGColor,
                             (id)[UIColor colorWithRed:red green:green blue:blue alpha:0.6f].CGColor,
//                             (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
//                             (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
//                             (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
//                             (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
//                             (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
//                             (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                             nil];
        shineLayer.locations = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0f],
//                                [NSNumber numberWithFloat:0.5f],
//                                [NSNumber numberWithFloat:0.5f],
//                                [NSNumber numberWithFloat:0.8f],
                                [NSNumber numberWithFloat:1.0f],
                                nil];
    }
    
    if ([view isKindOfClass:[UIButton class]]) {
        [layer addSublayer:shineLayer];
    }
    else {
        [layer insertSublayer:shineLayer atIndex:0];
    }

}

@end
