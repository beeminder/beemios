//
//  BeeminderAppDelegate.h
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeeminderAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Goal* sessionGoal;

- (NSURL *)applicationDocumentsDirectory;

+ (UIButton *)standardGrayButtonWith:(UIButton *)button;
+ (UIColor *)grayButtonColor;
+ (NSDictionary *)goalTypesInfo;
+ (Goal *)sharedSessionGoal;
+ (NSString *)slugFromTitle:(NSString *)title;
+ (void)clearSessionGoal;

@end
