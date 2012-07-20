//
//  Datapoint.h
//  Beeminder
//
//  Created by Andy Brett on 7/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Goal;

@interface Datapoint : NSManagedObject

@property (nonatomic, retain) NSNumber * comment;
@property (nonatomic, retain) NSNumber * measured_at;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) NSDecimalNumber * value;
@property (nonatomic, retain) Goal *goal;

@end
