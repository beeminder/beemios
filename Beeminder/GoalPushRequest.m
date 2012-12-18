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
    return [GoalPushRequest requestForGoal:goal additionalParams:nil withSuccessBlock:nil];
}

+ (GoalPushRequest *)requestForGoal:(Goal *)goal additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock
{
    return [GoalPushRequest requestForGoal:goal roadDial:NO additionalParams:additionalParams withSuccessBlock:successBlock withErrorBlock:nil];
}

+ (GoalPushRequest *)roadDialRequestForGoal:(Goal *)goal withSuccessBlock:(CompletionBlock)successBlock
{
    return [GoalPushRequest requestForGoal:goal roadDial:YES additionalParams:nil withSuccessBlock:successBlock withErrorBlock:nil];
}

+ (GoalPushRequest *)requestForGoal:(Goal *)goal roadDial:(BOOL)roadDial additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock
{
    GoalPushRequest *goalPushRequest = [[GoalPushRequest alloc] init];
    
    NSDictionary *allParams = [goal paramsDict];
    
    if (additionalParams) {
        allParams = [NSDictionary dictionaryByMerging:allParams with:additionalParams];
    }
    
    __block NSString *pString = @"";
    
    pString = [pString stringByAppendingFormat:@"access_token=%@", [ABCurrentUser accessToken]];
    
    [allParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"goaldate"]) {
            pString = [pString stringByAppendingFormat:@"&%@=%f", key, [obj doubleValue]];
        }
        else if ([[allParams objectForKey:key] isMemberOfClass:[NSNumber class]]) {
            pString = [pString stringByAppendingFormat:@"&%@=%g", key, [obj doubleValue]];
        }
        else {
            pString = [pString stringByAppendingFormat:@"&%@=%@", key, obj];
        }
    }];
    
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
    
    AFJSONRequestOperation *afRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        if (response.statusCode == 200) {
            [[NSManagedObjectContext MR_defaultContext] MR_save];
        }
        else if (!goal.serverId) {
            [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
        }
        if (successBlock) successBlock();
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
        if (errorBlock) errorBlock();
        if (!goal.serverId) {
            [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
            [[NSManagedObjectContext MR_defaultContext] MR_save];
        }
    }];
    
    [afRequest start];
    
    return goalPushRequest;
}

@end
