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
    
    if (goal.serverId) {
        urlString = [goal updateURL];
    }
    else {
        urlString = [goal createURL];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[goalPushRequest paramString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:goalPushRequest];
    
    if (connection) {
        goalPushRequest.status = @"sent";
    }
    
    return goalPushRequest;
}


@end
