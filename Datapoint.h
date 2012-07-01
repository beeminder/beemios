//
//  Datapoint.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Goal;

@interface Datapoint : NSManagedObject

@property (nonatomic) int64_t comment;
@property (nonatomic) int64_t measured_at;
@property (nonatomic, retain) NSDecimalNumber * value;
@property (nonatomic) int64_t serverId;
@property (nonatomic, retain) Goal *goal;

@end
