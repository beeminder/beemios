//
//  User+Create.m
//  Beeminder
//
//  Created by Andy Brett on 6/24/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User+Create.h"

@implementation User (Create)

+ (User *)userWithUserDict:(NSDictionary *)userDict withContext:(NSManagedObjectContext *)context
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
        user.username = [userDict objectForKey:@"username"];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    else {
        user = [users lastObject];
    }
    return user;
}

@end
