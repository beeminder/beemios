//
//  Goal.h
//  Beeminder
//
//  Created by Andy Brett on 6/24/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Datapoint, User;

@interface Goal : NSManagedObject

@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSNumber * goal;
@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSDecimalNumber * rate;
@property (nonatomic, retain) NSNumber * safebuf;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *datapoints;
@property (nonatomic, retain) User *user;
@end

@interface Goal (CoreDataGeneratedAccessors)

- (void)addDatapointsObject:(Datapoint *)value;
- (void)removeDatapointsObject:(Datapoint *)value;
- (void)addDatapoints:(NSSet *)values;
- (void)removeDatapoints:(NSSet *)values;

@end
