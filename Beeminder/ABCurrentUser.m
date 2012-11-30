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
}

+ (void)loginWithUsername:(NSString *)username accessToken:(NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:@"accessToken"];
    
    [defaults setObject:username forKey:@"username"];
    
    if (YES){//[[NSUserDefaults standardUserDefaults] boolForKey:kDidAllowRemoteNotificationsKey]) {
        [BeeminderAppDelegate requestPushNotificationAccess];
    }
    
}

+ (void)setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
}

+ (int)lastUpdatedAt
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"lastUpdatedAt-%@", [ABCurrentUser username]]];
}

+ (void)setLastUpdatedAtToNow
{
    [[NSUserDefaults standardUserDefaults] setInteger:(int)[[NSDate date] timeIntervalSince1970] forKey:[NSString stringWithFormat:@"lastUpdatedAt-%@", [ABCurrentUser username]]];
}

+ (void)resetLastUpdatedAt
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"lastUpdatedAt-%@", [ABCurrentUser username]]];
}

@end
