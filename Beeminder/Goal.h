//
//  Goal.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Datapoint, User;

@interface Goal : NSManagedObject

@property (nonatomic) int64_t date;
@property (nonatomic) double goal;
@property (nonatomic) double rate;
@property (nonatomic) int64_t safebuf;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * units;
@property (nonatomic, retain) NSString * gtype;
@property (nonatomic, retain) NSSet *datapoints;
@property (nonatomic, retain) User *user;
@end

@interface Goal (CoreDataGeneratedAccessors)

- (void)addDatapointsObject:(Datapoint *)value;
- (void)removeDatapointsObject:(Datapoint *)value;
- (void)addDatapoints:(NSSet *)values;
- (void)removeDatapoints:(NSSet *)values;

@end
