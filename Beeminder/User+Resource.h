//
//  User+Resource.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User.h"
#import "constants.h"
#import "Goal.h"
#import "UserPushRequest.h"

@interface User (Resource)

+ (User *)findByUsername:(NSString *)username inContext:(NSManagedObjectContext *)context;
+ (User *)writeToUserWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context;
- (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict inContext:(NSManagedObjectContext *)context;
- (void)pushToRemote;
- (NSString *)createURL;
- (NSString *)readURL;
- (NSString *)updateURL;
- (NSString *)deleteURL;

@end
