//
//  GoalPushRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalPushRequest.h"

@implementation GoalPushRequest

+ (void)requestForGoal:(Goal *)goal
{
    [GoalPushRequest requestForGoal:goal additionalParams:nil withSuccessBlock:nil];
}

+ (void)requestForGoal:(Goal *)goal additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock
{
    [GoalPushRequest requestForGoal:goal roadDial:NO additionalParams:additionalParams withSuccessBlock:successBlock withErrorBlock:nil];
}

+ (void)requestForGoal:(Goal *)goal roadDial:(BOOL)roadDial additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock
{
    NSDictionary *allParams = [goal paramsDict];
    allParams = [NSDictionary dictionaryByMerging:allParams with:[NSDictionary dictionaryWithObjectsAndKeys:[ABCurrentUser accessToken], @"access_token", nil]];
    
    if (additionalParams) allParams = [NSDictionary dictionaryByMerging:allParams with:additionalParams];
    
    NSString *url;
    if (goal.serverId) {
        allParams = [NSDictionary dictionaryByMerging:allParams with:[NSDictionary dictionaryWithObjectsAndKeys:@"PUT", @"_method", nil]];
        url = [goal updateURL];
    }
    else {
        url = [goal createURL];
    }
    
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager POST:url parameters:allParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == 200) {
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        else if (!goal.serverId) {
            [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }
        if (successBlock) successBlock();

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock();
        if (!goal.serverId) {
            [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        }

    }];
}

@end
