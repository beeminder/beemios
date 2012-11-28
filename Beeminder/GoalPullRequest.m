//
//  GoalPullRequest.m
//  Beeminder
//
//  Created by Andy Brett on 10/10/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalPullRequest.h"

@implementation GoalPullRequest

+ (GoalPullRequest *)requestForGoal:(Goal *)goal withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock
{
    GoalPullRequest *goalPullRequest = [[GoalPullRequest alloc] init];
    
    NSURL *url = [NSURL URLWithString:[[goal readURL] stringByAppendingFormat:@"?access_token=%@", [ABCurrentUser accessToken]]];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    AFJSONRequestOperation *afRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *modGoalDict = [Goal processGoalDictFromServer:JSON];
        [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];        
        if (successBlock) successBlock();
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
        if (errorBlock) errorBlock();
    }];
    [afRequest start];
    
    // right now we just return a newly allocated request.
    return goalPullRequest;
}

@end
