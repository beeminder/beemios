//
//  GoalSyncRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourceSyncRequest.h"
#import "Goal+Resource.h"

@interface GoalSyncRequest : ResourceSyncRequest

+ (GoalSyncRequest *)requestForGoal:(Goal *)goal;

@end
