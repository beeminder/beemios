//
//  ABCurrentUser.m
//  Beeminder
//
//  Created by Andy Brett on 8/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ABCurrentUser.h"

@implementation ABCurrentUser

+ (User *)user
{
    return [User MR_findFirstByAttribute:@"username" withValue:[ABCurrentUser username] inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (NSString *)username
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
}

+ (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
}

+ (void)logout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [BeeminderAppDelegate removeDeviceTokenFromServer];
    [defaults removeObjectForKey:@"accessToken"];
    [defaults removeObjectForKey:@"username"];
    [BeeminderAppDelegate removeStoredOAuthDefaults];
    [defaults synchronize];
}

+ (void)loginWithUsername:(NSString *)username accessToken:(NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:@"accessToken"];
    
    [defaults setObject:username forKey:@"username"];
    
    [defaults synchronize];
}

+ (void)setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (int)lastUpdatedAt
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"lastUpdatedAt-%@", [ABCurrentUser username]]];
}

+ (BOOL)emergencyDayNotifications
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", kEmergencyKey, [ABCurrentUser username]]] boolValue];
}

+ (void)setEmergencyDayNotifications:(BOOL)on
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:on] forKey:[NSString stringWithFormat:@"%@-%@", kEmergencyKey, [ABCurrentUser username]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)emergencyNotificationDate
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", kEmergencyTimeKey, [ABCurrentUser username]]];
    if (date) {
        return date;
    }
    date = [BeeminderAppDelegate defaultEmergencyDayReminderDate];
    [ABCurrentUser setEmergencyNotificationDate:date];
    return date;
}

+ (void)setEmergencyNotificationDate:(NSDate *)date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:[NSString stringWithFormat:@"%@-%@", kEmergencyTimeKey, [ABCurrentUser username]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setLastUpdatedAtToNow
{
    [[NSUserDefaults standardUserDefaults] setInteger:(int)[[NSDate date] timeIntervalSince1970] forKey:[NSString stringWithFormat:@"lastUpdatedAt-%@", [ABCurrentUser username]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)resetLastUpdatedAt
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"lastUpdatedAt-%@", [ABCurrentUser username]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
