//
//  User+Resource.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User.h"
#import "Goal.h"
#import "UserPushRequest.h"

@interface User (Resource)

+ (User *)writeToUserWithDictionary:(NSDictionary *)userDict;
- (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict;
- (void)pushToRemote;
- (NSString *)createURL;
- (NSString *)readURL;
- (NSString *)updateURL;
- (NSString *)deleteURL;
- (NSString *)paramString;

@end
