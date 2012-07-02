//
//  UserPushRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourcePushRequest.h"
#import "User+Resource.h"

@interface UserPushRequest : ResourcePushRequest

+ (UserPushRequest *)requestForUser:(User *)user syncAssociations:(BOOL)syncAssociations;

@end
