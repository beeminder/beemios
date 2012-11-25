//
//  BeeminderAppDelegate.h
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import "TwitterAuthDelegate.h"

@interface BeeminderAppDelegate : UIResponder <UIApplicationDelegate>

extern NSString *const FBSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Goal* sessionGoal;

- (NSURL *)applicationDocumentsDirectory;

+ (UIButton *)standardGrayButtonWith:(UIButton *)button;
+ (UIColor *)grayButtonColor;
+ (NSDictionary *)goalTypesInfo;
+ (Goal *)sharedSessionGoal;
+ (NSString *)slugFromTitle:(NSString *)title;
+ (void)clearSessionGoal;
+ (AFHTTPRequestOperation *)reverseAuthTokenOperationForTwitterAccount:(ACAccount *)twitterAccount;
+ (void)requestAccessToTwitterFromView:(UIView *)view withDelegate:(id<UIActionSheetDelegate, TwitterAuthDelegate>)delegate;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end
