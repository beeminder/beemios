//
//  UserPushRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User+Resource.h"
#import "GoalPushRequest.h"
#import "NSDictionary+Merge.h"

@interface UserPushRequest : NSObject

+ (void)requestForUser:(User *)user pushAssociations:(BOOL)pushAssociations additionalParams:(NSDictionary *)additionalParams successBlock:(CompletionBlock)successBlock errorBlock:(CompletionBlock)errorBlock;

@end
