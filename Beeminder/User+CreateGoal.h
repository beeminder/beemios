//
//  User+CreateGoal.h
//  Beeminder
//
//  Created by Andy Brett on 6/24/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "User.h"

@interface User (CreateGoal)

- (Goal *)addGoalFromDictionary:(NSDictionary *)goalDict inManagedObjectContext:(NSManagedObjectContext *)context;

@end
