//
//  GoalPullRequest.m
//  Beeminder
//
//  Created by Andy Brett on 10/10/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalPullRequest.h"

@implementation GoalPullRequest

+ (void)requestForGoal:(Goal *)goal withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[ABCurrentUser accessToken], @"access_token", nil];
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager GET:[goal readURL] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *modGoalDict = [Goal processGoalDictFromServer:responseObject];
        [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];
        if (successBlock) successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock();
    }];
}

@end
