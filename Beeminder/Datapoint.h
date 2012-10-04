//
//  Datapoint.h
//  Beeminder
//
//  Created by Andy Brett on 10/2/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Goal;

@interface Datapoint : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * serverId;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSDecimalNumber * value;
@property (nonatomic, retain) Goal *goal;

@end
