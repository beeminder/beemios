//
//  UITabBarController+autoRotate.h
//  Beeminder
//
//  Created by Andy Brett on 10/9/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (autoRotate)

-(BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@end
