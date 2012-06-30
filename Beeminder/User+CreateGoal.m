//
//  User+CreateGoal.m
//  Beeminder
//
//  Created by Andy Brett on 6/24/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User+CreateGoal.h"
#import "User.h"
#import "Goal.h"

@implementation User (CreateGoal)

- (Goal *)addGoalFromDictionary:(NSDictionary *)goalDict inManagedObjectContext:(NSManagedObjectContext *)context
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
        goal.slug = [goalDict objectForKey:@"slug"];
        goal.title = [goalDict objectForKey:@"title"];
        goal.gtype = [goalDict objectForKey:@"gtype"];
        
        // other attributes here.
        
        [self addGoalsObject:goal];
    }
    [context save:nil];
    return goal;
}

@end
