//
//  UsernameCachePullRequest.h
//  Beeminder
//
//  Created by Andy Brett on 7/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourcePullRequest.h"
#import "UsernameCache+Resource.h"
#import "SBJson.h"

@interface UsernameCachePullRequest : ResourcePullRequest

@property (strong, nonatomic) UsernameCache *usernameCache;

+ (UsernameCachePullRequest *)requestInContext:(NSManagedObjectContext *)context;

@end
