//
//  GoalPushRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Resource.h"
typedef void(^CompletionBlock)();

@interface GoalPushRequest : NSObject

+ (void)requestForGoal:(Goal *)goal;

+ (void)requestForGoal:(Goal *)goal additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock;

+ (void)requestForGoal:(Goal *)goal roadDial:(BOOL)roadDial additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock;

@end
