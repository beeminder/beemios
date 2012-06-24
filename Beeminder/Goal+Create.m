//
//  Goal+Create.m
//  Beeminder
//
//  Created by Andy Brett on 6/24/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Create.h"
#import "User.h"

@implementation Goal (Create)

+ (Goal *)goalWithDictionary:(NSDictionary *)goalDict 
   forUserWithUsername:(NSString *)username 
   inManagedObjectContext:(NSManagedObjectContext *)context
{
    Goal *goal = nil;
    User *user = nil;
    
    NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    userRequest.predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSSortDescriptor *userSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES];
    userRequest.sortDescriptors = [NSArray arrayWithObject:userSortDescriptor];
    
    NSArray *users = [context executeFetchRequest:userRequest error:NULL];
    
    if (!users || users.count > 1) {
        // error
    }
    else if (users.count == 0) {
        // shouldn't get here. could create a new user?
    }
    else {
        user = [users lastObject];
    }
    
    Goal *g = nil;
    
    for (g in user.goals) {
        if (g.slug == [goalDict objectForKey:@"slug"]) {
            goal = g;
        }
    }
    
    if (!goal) {
        // create
        goal = [NSEntityDescription insertNewObjectForEntityForName:@"Goal" inManagedObjectContext:context];
        goal.slug = [goalDict objectForKey:@"slug"];
        goal.title = [goalDict objectForKey:@"title"];
        // other attributes here.
        [user addGoalsObject:goal];
    }
    
    return goal;
}

@end
