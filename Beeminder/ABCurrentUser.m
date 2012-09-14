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
    return [User MR_findFirstByAttribute:@"username" withValue:[ABCurrentUser username]];
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
    [defaults setObject:nil forKey:@"accessToken"];
    [defaults setObject:nil forKey:@"username"];
    [defaults setInteger:0 forKey:@"lastUpdatedAt"];
}

+ (void)loginWithUsername:(NSString *)username accessToken:(NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:@"accessToken"];
    
    [defaults setObject:username forKey:@"username"];
    
}

+ (void)setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
}

@end
