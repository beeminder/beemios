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

+ (NSString *)authenticationToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];
}

+ (void)logout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"authenticationTokenKey"];
    [defaults setObject:nil forKey:@"username"];
}

+ (void)loginWithUsername:(NSString *)username authenticationToken:(NSString *)authenticationToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:authenticationToken forKey:@"authenticationTokenKey"];
    
    [defaults setObject:username forKey:@"username"];
    
}

+ (void)setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
}

@end
