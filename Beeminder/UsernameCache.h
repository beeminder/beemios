//
//  UsernameCache.h
//  Beeminder
//
//  Created by Andy Brett on 7/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UsernameCache : NSManagedObject

@property (nonatomic) int64_t lastFetched;
@property (nonatomic, retain) NSString * usernameList;

@end
