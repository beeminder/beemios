//
//  Goal+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Resource.h"

@implementation Goal (Resource)

+ (Goal *)findBySlug:(NSString *)slug forUserWithUsername:(NSString *)username inContext:(NSManagedObjectContext *)context
{
    Goal *goal = nil;
    
    NSFetchRequest *goalRequest = [NSFetchRequest fetchRequestWithEntityName:@"Goal"];
    
    goalRequest.predicate = [NSPredicate predicateWithFormat:@"user.username = %@ and slug = %@", username, slug];
    
    NSArray *goals = [context executeFetchRequest:goalRequest error:NULL];
    
    if (!goals || goals.count > 1) {
        // error
    }
    else {
        goal = [goals lastObject];
    }
    return goal;
}

+ (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict
    forUserWithUsername:(NSString *)username
    inContext:(NSManagedObjectContext *)context
{
    User *user = [User findByUsername:username inContext:context];
    
    Goal *goal = [user writeToGoalWithDictionary:goalDict inContext:context];
    [context save:nil];
    return goal;
}

- (void)pushToRemote
{
    [GoalPushRequest requestForGoal:self];
}

- (NSString *)createURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@/goals.json", kBaseURL, kAPIPrefix, self.user.username];
}

- (NSString *)readURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json", kBaseURL, kAPIPrefix, self.user.username, self.serverId];
}

- (NSString *)updateURL
{
    return [self readURL];
}

- (NSString *)deleteURL
{
    return [self readURL];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *key in [[self.entity attributesByName] allKeys]) {
        NSString * val = [self performSelector:NSSelectorFromString(key)];
        [dict setObject:val forKey:key];
    }
    return dict;
}


@end
