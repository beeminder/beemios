//
//  User+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User+Resource.h"
#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

@implementation User (Resource)

+ (User *)writeToUserWithDictionary:(NSDictionary *)userDict
{
    User *user = [User MR_findFirstByAttribute:@"username" withValue:[userDict objectForKey:@"username"] inContext:[NSManagedObjectContext MR_defaultContext]];
    
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
            // since we send the "skinny" parameter now, we shouldn't get this key back.
            NSDictionary *datapointDict;
            for (datapointDict in obj) {
                Datapoint *datapoint = [Datapoint MR_findFirstByAttribute:@"serverId" withValue:[datapointDict objectForKey:@"id"] inContext:[NSManagedObjectContext MR_defaultContext]];
                if (!datapoint) {
                    datapoint = [Datapoint MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
                }
                datapoint.goal = goal;
                datapoint.comment = [datapointDict objectForKey:@"comment"];
                datapoint.value = [datapointDict objectForKey:@"value"];
                datapoint.serverId = [datapointDict objectForKey:@"id"];
                datapoint.timestamp = [datapointDict objectForKey:@"timestamp"];
                [defaultContext MR_save];
            }
        }
        else if ([key isEqualToString:@"last_datapoint"] && NULL_TO_NIL(obj)) {
            Datapoint *datapoint = [Datapoint MR_findFirstByAttribute:@"serverId" withValue:[obj objectForKey:@"id"] inContext:[NSManagedObjectContext MR_defaultContext]];
            if (!datapoint) {
                datapoint = [Datapoint MR_createInContext:[NSManagedObjectContext MR_defaultContext]];
            }
            datapoint.goal = goal;
            datapoint.comment = [obj objectForKey:@"comment"];
            datapoint.value = [obj objectForKey:@"value"];
            datapoint.serverId = [obj objectForKey:@"id"];
            datapoint.timestamp = [obj objectForKey:@"timestamp"];
            [defaultContext MR_save];
        }
        else {
            NSString *selectorString = [NSString stringWithFormat:@"set%@:", [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]]];
            
            if ([goal respondsToSelector:NSSelectorFromString(selectorString)]) {
                [goal performSelector:NSSelectorFromString(selectorString) withObject:NULL_TO_NIL(obj)];
            }
        }
    }
    ];
    
    [defaultContext MR_save];
    return goal;
}

- (void)pushToRemote
{
    [UserPushRequest requestForUser:self pushAssociations:NO additionalParams:nil successBlock:nil errorBlock:nil];
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

- (NSString *)paramString
{
    return [NSString stringWithFormat:@"username=%@&email=%@", self.username, self.email];
}

@end
