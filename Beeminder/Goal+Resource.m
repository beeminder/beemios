//
//  Goal+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Resource.h"

@implementation Goal (Resource)

+ (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict
    forUserWithUsername:(NSString *)username
{
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    User *user = [User MR_findFirstByAttribute:@"username" withValue:username inContext:defaultContext];
    
    Goal *goal = [user writeToGoalWithDictionary:goalDict];
    [defaultContext save:nil];
    return goal;
}

- (void)pushToRemoteWithCompletionBlock:(CompletionBlock)completionBlock
{
    [GoalPushRequest requestForGoal:self withCompletionBlock:completionBlock];
}

- (NSString *)createURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@/goals.json", kBaseURL, kAPIPrefix, self.user.username];
}

- (NSString *)readURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json", kBaseURL, kAPIPrefix, self.user.username, self.slug];
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
        if (val) {
            [dict setObject:val forKey:key];
        }

    }
    return dict;
}

@end
