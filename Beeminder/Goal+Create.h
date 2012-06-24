//
//  Goal+Create.h
//  Beeminder
//
//  Created by Andy Brett on 6/24/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal.h"

@interface Goal (Create)

+ (Goal *)goalWithDictionary:(NSDictionary *)goalDict forUserWithUsername:(NSString *)username inManagedObjectContext:(NSManagedObjectContext *)context;

@end
