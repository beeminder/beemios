//
//  UserPushRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourcePushRequest.h"
#import "User+Resource.h"
#import "GoalPushRequest.h"
#import "SBJson.h"

@interface UserPushRequest : ResourcePushRequest

+ (UserPushRequest *)requestForUser:(User *)user pushAssociations:(BOOL)pushAssociations additionalParams:(NSDictionary *)additionalParams completionBlock:(CompletionBlock)completionBlock;

@end
