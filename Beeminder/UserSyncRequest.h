//
//  UserSyncRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourceSyncRequest.h"
#import "User+Resource.h"

@interface UserSyncRequest : ResourceSyncRequest

+ (UserSyncRequest *)requestForUser:(User *)user;

@end
