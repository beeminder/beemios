//
//  User+Find.h
//  Beeminder
//
//  Created by Andy Brett on 6/27/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User.h"

@interface User (Find)

+ (User *)findByUsername:(NSString *)username withContext:(NSManagedObjectContext *)context;

@end
