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

+ (GoalPushRequest *)requestForGoal:(Goal *)goal;

+ (GoalPushRequest *)requestForGoal:(Goal *)goal additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock;

+ (GoalPushRequest *)roadDialRequestForGoal:(Goal *)goal withSuccessBlock:(CompletionBlock)successBlock;

+ (GoalPushRequest *)requestForGoal:(Goal *)goal roadDial:(BOOL)roadDial additionalParams:(NSDictionary *)additionalParams withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock;

@end
