//
//  Goal+Find.m
//  Beeminder
//
//  Created by Andy Brett on 6/29/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Find.h"

@implementation Goal (Find)

+ (Goal *)findBySlug:(NSString *)slug forUserWithUsername:(NSString *)username withContext:(NSManagedObjectContext *)context
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

@end
