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

@interface BeeminderAppDelegate : UIResponder <UIApplicationDelegate>

extern NSString *const FBSessionStateChangedNotification;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Goal* sessionGoal;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) AFHTTPRequestOperationManager *operationManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *imageOperationManager;

- (NSURL *)applicationDocumentsDirectory;

+ (UIButton *)standardGrayButtonWith:(UIButton *)button;
+ (UIColor *)grayButtonColor;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

+ (AFHTTPRequestOperation *)reverseAuthTokenOperationForTwitterAccount:(ACAccount *)twitterAccount;
+ (void)requestAccessToTwitterFromView:(UIView *)view withDelegate:(id<UIActionSheetDelegate, TwitterAuthDelegate>)delegate;
+ (void)fetchAccessTokenForTwitterAccount:twitterAccount authParams:authParams withDelegate:(id<TwitterAuthDelegate>)delegate;
+ (void)getReverseAuthTokensForTwitterAccount:(ACAccount *)twitterAccount fromView:(UIView *)view withDelegate:(id<TwitterAuthDelegate>)delegate;

+ (NSString *)encodedString:(NSString *)string;
+ (NSString *)hmacSha1SignatureForBaseString:(NSString *)baseString andKey:(NSString *)key;
+ (NSDictionary *)addDeviceTokenToParamsDict:(NSDictionary *)paramsDict;
+ (void)removeStoredOAuthDefaults;

+ (NSDate *)defaultEnterDataReminderDate;
+ (NSDate *)defaultEmergencyDayReminderDate;
+ (void)scheduleEnterDataReminders;

+ (void)requestPushNotificationAccess;
+ (void)updateApplicationIconBadgeCount;

+ (void)removeDeviceTokenFromServer;

+ (UIColor *)silverColor;
+ (UIColor *)cloudsColor;
+ (UIColor *)sunflowerColor;
+ (UIColor *)concreteColor;
+ (UIColor *)nephritisColor;

@end
