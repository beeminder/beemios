//
//  GoalSyncRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalSyncRequest.h"

@implementation GoalSyncRequest

+ (GoalSyncRequest *)requestForGoal:(Goal *)goal
{
    GoalSyncRequest *goalSyncRequest = [[GoalSyncRequest alloc] init];
    goalSyncRequest.resource = goal;
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
    [request setHTTPBody:[[goalSyncRequest paramString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:goalSyncRequest];
    
    if (connection) {
        goalSyncRequest.status = @"sent";
    }
    
    return goalSyncRequest;
}


@end
