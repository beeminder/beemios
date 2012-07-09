//
//  GoalPushRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalPushRequest.h"

@implementation GoalPushRequest

+ (GoalPushRequest *)requestForGoal:(Goal *)goal
{
    GoalPushRequest *goalPushRequest = [[GoalPushRequest alloc] init];
    goalPushRequest.resource = goal;
    NSString *urlString;
    
    if ([goal.serverId intValue] == 0) {
        urlString = [goal createURL];
    }
    else {
        urlString = [goal updateURL];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *pString = [goalPushRequest paramString];
    pString = [pString stringByAppendingFormat:@"auth_token=%@&", [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[pString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:goalPushRequest];
    
    if (connection) {
        goalPushRequest.status = @"sent";
    }
    
    return goalPushRequest;
}


@end
