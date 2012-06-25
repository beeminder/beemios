//
//  User+Create.h
//  Beeminder
//
//  Created by Andy Brett on 6/24/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User.h"

@interface User (Create)

+ (User *)userWithUserDict:(NSDictionary *)userDict withContext:(NSManagedObjectContext *)context;

@end
