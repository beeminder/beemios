//
//  Goal+Find.h
//  Beeminder
//
//  Created by Andy Brett on 6/29/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal.h"

@interface Goal (Find)

+ (Goal *)findBySlug:(NSString *)slug forUserWithUsername:(NSString *)username withContext:(NSManagedObjectContext *)context;

@end
