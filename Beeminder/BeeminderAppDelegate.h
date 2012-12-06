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
#import "MainTabBarViewController.h"
#import "GoalsTableViewController.h"

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

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

+ (AFHTTPRequestOperation *)reverseAuthTokenOperationForTwitterAccount:(ACAccount *)twitterAccount;
+ (void)requestAccessToTwitterFromView:(UIView *)view withDelegate:(id<UIActionSheetDelegate, TwitterAuthDelegate>)delegate;
+ (void)fetchAccessTokenForTwitterAccount:twitterAccount authParams:authParams withDelegate:(id<TwitterAuthDelegate>)delegate;
+ (void)getReverseAuthTokensForTwitterAccount:(ACAccount *)twitterAccount fromView:(UIView *)view withDelegate:(id<TwitterAuthDelegate>)delegate;

+ (NSString *)hmacSha1SignatureForBaseString:(NSString *)baseString andKey:(NSString *)key;
+ (NSString *)addDeviceTokenToParamString:(NSString *)paramString;
+ (void)removeStoredOAuthDefaults;

+ (NSDate *)defaultEnterDataReminderDate;
+ (NSDate *)defaultEmergencyDayReminderDate;
+ (void)scheduleEnterDataReminders;

+ (void)requestPushNotificationAccess;
+ (void)updateApplicationIconBadgeCount;
- (void)refreshGoalsAndShowDashboard;

+ (void)removeDeviceTokenFromServer;
@end
