//
//  User+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User+Resource.h"

@implementation User (Resource)

+ (User *)findByUsername:(NSString *)username inContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    userRequest.predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    
    NSArray *users = [context executeFetchRequest:userRequest error:NULL];
    
    if (!users || users.count > 1) {
        // error
    }
    else {
        user = [users lastObject];
    }
    return user;
}

+ (User *)writeToUserWithDictionary:(NSDictionary *)userDict inContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    userRequest.predicate = [NSPredicate predicateWithFormat:@"username = %@", [userDict objectForKey:@"username"]];
    NSSortDescriptor *userSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES];
    userRequest.sortDescriptors = [NSArray arrayWithObject:userSortDescriptor];
    
    NSArray *users = [context executeFetchRequest:userRequest error:NULL];
    
    if (!users || users.count > 1) {
        // error
    }
    else if (users.count == 0) {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    }
    else {
        user = [users lastObject];
    }
    
    [userDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
    {
        NSString *selectorString = [NSString stringWithFormat:@"set%@:", [key capitalizedString] ];
        if ([user respondsToSelector:NSSelectorFromString(selectorString)]) {
            [user performSelector:NSSelectorFromString(selectorString) withObject:obj];
            }
    }
    ];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return user;
}

- (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict inContext:(NSManagedObjectContext *)context
{
    Goal *goal;
    Goal *g;
    NSSet *goals = self.goals;
    for (g in goals) {
        if ([g.slug isEqualToString:[goalDict objectForKey:@"slug"]]) {
            goal = g;
        }
    }
    
    if (!goal) {
        goal = [NSEntityDescription insertNewObjectForEntityForName:@"Goal" inManagedObjectContext:context];
        [self addGoalsObject:goal];
    }
    
    [goalDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
    {
        NSString *selectorString = [NSString stringWithFormat:@"set%@:", [key capitalizedString] ];
        if ([goal respondsToSelector:NSSelectorFromString(selectorString)]) {
            [goal performSelector:NSSelectorFromString(selectorString) withObject:obj];
        }
    }
    ];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [context save:nil];
    return goal;
}

- (void)pushToRemote
{
    [UserPushRequest requestForUser:self syncAssociations:NO additionalParams:nil];
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
