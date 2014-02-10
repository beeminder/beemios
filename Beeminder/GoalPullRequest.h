//
//  GoalPullRequest.h
//  Beeminder
//
//  Created by Andy Brett on 10/10/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoalPullRequest : NSObject

+ (void)requestForGoal:(Goal *)goal withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock;

@end
