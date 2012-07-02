//
//  UsernameCache+Resource.h
//  Beeminder
//
//  Created by Andy Brett on 7/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UsernameCache.h"
#import "constants.h"

@interface UsernameCache (Resource)

- (NSString *)readURL;
+ (NSString *)readURL;

@end
