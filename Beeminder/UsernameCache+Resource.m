//
//  UsernameCache+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 7/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UsernameCache+Resource.h"

@implementation UsernameCache (Resource)

- (NSString *)readURL
{
    NSString *timestamp = @"";
    
    if (self.lastFetched) {
        timestamp = [NSString stringWithFormat:@"%llu", self.lastFetched];
    }

    return [NSString stringWithFormat:@"%@/%@/usernames.json?timestamp=%@", kBaseURL, kPrivateAPIPrefix, timestamp];
}

@end
