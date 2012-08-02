//
//  Goal.h
//  Beeminder
//
//  Created by Andy Brett on 8/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Datapoint, User;

@interface Goal : NSManagedObject

@property (nonatomic, retain) NSString * countdown;
@property (nonatomic, retain) NSNumber * ephem;
@property (nonatomic, retain) NSNumber * goaldate;
@property (nonatomic, retain) NSNumber * goalval;
@property (nonatomic, retain) NSString * gtype;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * units;
@property (nonatomic, retain) NSString * graph_url;
@property (nonatomic, retain) NSSet *datapoints;
@property (nonatomic, retain) User *user;
@end

@interface Goal (CoreDataGeneratedAccessors)

- (void)addDatapointsObject:(Datapoint *)value;
- (void)removeDatapointsObject:(Datapoint *)value;
- (void)addDatapoints:(NSSet *)values;
- (void)removeDatapoints:(NSSet *)values;

@end
