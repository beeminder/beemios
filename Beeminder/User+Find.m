//
//  User+Find.m
//  Beeminder
//
//  Created by Andy Brett on 6/27/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User+Find.h"

@implementation User (Find)

+ (User *)findByUsername:(NSString *)username withContext:(NSManagedObjectContext *)context
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

@end
