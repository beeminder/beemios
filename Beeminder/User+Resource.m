//
//  User+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User+Resource.h"

@implementation User (Resource)

+ (User *)writeToUserWithDictionary:(NSDictionary *)userDict
{
    User *user = [User MR_findFirstByAttribute:@"username" withValue:[userDict objectForKey:@"username"]];
    
    if (!user) user = [User MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
    
    [userDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
    {
        NSString *selectorString = [NSString stringWithFormat:@"set%@:", [key capitalizedString] ];
        if ([user respondsToSelector:NSSelectorFromString(selectorString)]) {
            [user performSelector:NSSelectorFromString(selectorString) withObject:obj];
            }
    }
    ];
    
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    return user;
}

- (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict
{
    Goal *goal;
    Goal *g;
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    
    NSSet *goals = self.goals;
    for (g in goals) {
        if ([g.slug isEqualToString:[goalDict objectForKey:@"slug"]]) {
            goal = g;
        }
    }
    
    if (!goal) {
        goal = [Goal MR_createInContext:localContext];
        [self addGoalsObject:goal];
    }
    
    [goalDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
    {
        NSString *selectorString = [NSString stringWithFormat:@"set%@:", [key capitalizedString] ];
        if ([goal respondsToSelector:NSSelectorFromString(selectorString)] && obj != [NSNull null]) {
            [goal performSelector:NSSelectorFromString(selectorString) withObject:obj];
        }
    }
    ];
    
    [localContext MR_save];
    return goal;
}

- (void)pushToRemote
{
    [UserPushRequest requestForUser:self pushAssociations:NO additionalParams:nil completionBlock:nil];
}

- (NSString *)createURL
{
    return [NSString stringWithFormat:@"%@/%@/users.json", kBaseURL, kAPIPrefix];
}

- (NSString *)readURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@.json", kBaseURL, kAPIPrefix, self.serverId];
}

- (NSString *)updateURL
{
    return [self readURL];
}

- (NSString *)deleteURL
{
    return [self readURL];
}

@end
