//
//  GoalPushRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalPushRequest.h"

@implementation GoalPushRequest


+ (GoalPushRequest *)requestForGoal:(Goal *)goal withCompletionBlock:(CompletionBlock)completionBlock
{
    return [GoalPushRequest requestForGoal:goal roadDial:NO withCompletionBlock:completionBlock];
}

+ (GoalPushRequest *)requestForGoal:(Goal *)goal roadDial:(BOOL)roadDial withCompletionBlock:(CompletionBlock)completionBlock
{
    GoalPushRequest *goalPushRequest = [[GoalPushRequest alloc] init];
    goalPushRequest.resource = goal;
    goalPushRequest.completionBlock = completionBlock;

    NSString *pString = [goalPushRequest paramString];
    pString = [pString stringByAppendingFormat:@"auth_token=%@&", [ABCurrentUser authenticationToken]];
    
    NSURL *url;
    NSMutableURLRequest *request;
    if (goal.serverId) {
        if (roadDial) {
            url = [NSURL URLWithString:[[goal roadDialURL] stringByAppendingFormat:@"?%@", pString]];
            request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
        }
        else {
            url = [NSURL URLWithString:[[goal updateURL] stringByAppendingFormat:@"?%@", pString]];
            request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"PUT"];
        }
    }
    else {
        url = [NSURL URLWithString:[goal createURL]];
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[pString dataUsingEncoding:NSUTF8StringEncoding]];        
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:goalPushRequest];
    
    if (connection) {
        goalPushRequest.responseData = [NSMutableData data];
        goalPushRequest.status = @"sent";
    }
    
    return goalPushRequest;
}

+ (GoalPushRequest *)roadDialRequestForGoal:(Goal *)goal withCompletionBlock:(CompletionBlock)completionBlock
{
    return [GoalPushRequest requestForGoal:goal roadDial:YES withCompletionBlock:completionBlock];
}

@end
