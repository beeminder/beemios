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
    
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    NSSet *goals = self.goals;
    for (g in goals) {
        if ([g.slug isEqualToString:[goalDict objectForKey:@"slug"]]) {
            goal = g;
        }
    }
    
    if (!goal) {
        goal = [Goal MR_createInContext:defaultContext];
        [self addGoalsObject:goal];
    }
    
    [goalDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
    {
        if ([key isEqualToString:@"datapoints"]) {
            NSDictionary *datapointDict;
            for (datapointDict in obj) {
                Datapoint *datapoint = [Datapoint MR_findFirstByAttribute:@"serverId" withValue:[datapointDict objectForKey:@"id"]];
                if (!datapoint) {
                    datapoint = [Datapoint MR_createEntity];
                }
                datapoint.goal = goal;
                datapoint.comment = [datapointDict objectForKey:@"comment"];
                datapoint.value = [datapointDict objectForKey:@"value"];
                datapoint.serverId = [datapointDict objectForKey:@"id"];
                datapoint.timestamp = [datapointDict objectForKey:@"timestamp"];
                [defaultContext MR_save];
            }
        }
        else {
            NSString *selectorString = [NSString stringWithFormat:@"set%@:", [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]]];
            if ([goal respondsToSelector:NSSelectorFromString(selectorString)] && obj != [NSNull null]) {
                [goal performSelector:NSSelectorFromString(selectorString) withObject:obj];
            }
        }
    }
    ];
    
    [defaultContext MR_save];
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
    return [NSString stringWithFormat:@"%@/%@/users/%@.json", kBaseURL, kAPIPrefix, self.username];
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
