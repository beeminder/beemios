//
//  Goal.h
//  Beeminder
//
//  Created by Andy Brett on 12/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Datapoint, User;

@interface Goal : NSManagedObject

@property (nonatomic, retain) NSString * burner;
@property (nonatomic, retain) id contract;
@property (nonatomic, retain) NSNumber * ephem;
@property (nonatomic, retain) NSNumber * fitbit;
@property (nonatomic, retain) NSString * fitbit_field;
@property (nonatomic, retain) NSNumber * frozen;
@property (nonatomic, retain) NSString * goal_type;
@property (nonatomic, retain) NSNumber * goaldate;
@property (nonatomic, retain) NSNumber * goalval;
@property (nonatomic, retain) id graph_image;
@property (nonatomic, retain) id graph_image_thumb;
@property (nonatomic, retain) NSString * graph_url;
@property (nonatomic, retain) NSNumber * initval;
@property (nonatomic, retain) NSString * limsum;
@property (nonatomic, retain) NSNumber * losedate;
@property (nonatomic, retain) NSNumber * lost;
@property (nonatomic, retain) NSNumber * panic;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * thumb_url;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * units;
@property (nonatomic, retain) NSNumber * won;
@property (nonatomic, retain) NSSet *datapoints;
@property (nonatomic, retain) User *user;
@end

@interface Goal (CoreDataGeneratedAccessors)

- (void)addDatapointsObject:(Datapoint *)value;
- (void)removeDatapointsObject:(Datapoint *)value;
- (void)addDatapoints:(NSSet *)values;
- (void)removeDatapoints:(NSSet *)values;

@end
