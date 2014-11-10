//
//  User.h
//  Beeminder
//
//  Created by Andy Brett on 11/3/14.
//  Copyright (c) 2014 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Goal;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * hasAuthorizedFitbit;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *goals;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGoalsObject:(Goal *)value;
- (void)removeGoalsObject:(Goal *)value;
- (void)addGoals:(NSSet *)values;
- (void)removeGoals:(NSSet *)values;

@end
