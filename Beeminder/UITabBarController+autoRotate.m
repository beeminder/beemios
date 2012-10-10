//
//  UITabBarController+autoRotate.m
//  Beeminder
//
//  Created by Andy Brett on 10/9/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UITabBarController+autoRotate.h"
#import "GoalGraphViewController.h"

@implementation UITabBarController (autoRotate)

- (BOOL)shouldAutorotate
{
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navCon = (UINavigationController *)self.selectedViewController;
        if ([navCon.topViewController isMemberOfClass:[GoalGraphViewController class]]) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navCon = (UINavigationController *)self.selectedViewController;
        if ([navCon.topViewController isMemberOfClass:[GoalGraphViewController class]]) {
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
