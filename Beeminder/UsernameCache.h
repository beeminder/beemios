//
//  UsernameCache.h
//  Beeminder
//
//  Created by Andy Brett on 7/5/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UsernameCache : NSManagedObject

@property (nonatomic, retain) NSNumber * lastFetched;
@property (nonatomic, retain) NSString * usernameList;

@end
