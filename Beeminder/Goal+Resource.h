//
//  Goal+Resource.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal.h"
#import "constants.h"
#import "User+Resource.h"
#import "GoalPushRequest.h"

@interface Goal (Resource)

+ (Goal *)findBySlug:(NSString *)slug forUserWithUsername:(NSString *)username inContext:(NSManagedObjectContext *)context;

+ (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict
              forUserWithUsername:(NSString *)username
                        inContext:(NSManagedObjectContext *)context;
- (void)pushToRemote;
- (NSString *)createURL;
- (NSString *)readURL;
- (NSString *)updateURL;
- (NSString *)deleteURL;

@end
