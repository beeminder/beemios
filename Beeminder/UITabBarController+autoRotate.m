//
//  UITabBarController+autoRotate.m
//  Beeminder
//
//  Created by Andy Brett on 10/9/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UITabBarController+autoRotate.h"

@implementation UITabBarController (autoRotate)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
