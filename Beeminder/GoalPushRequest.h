//
//  GoalPushRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourcePushRequest.h"
#import "Goal+Resource.h"

@interface GoalPushRequest : ResourcePushRequest

@property NSUInteger responseStatus;
@property (strong, nonatomic) NSMutableData *responseData;

+ (GoalPushRequest *)requestForGoal:(Goal *)goal;

@end
