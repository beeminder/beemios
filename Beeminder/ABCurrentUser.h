//
//  ABCurrentUser.h
//  Beeminder
//
//  Created by Andy Brett on 8/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABCurrentUser : NSObject

+ (User *)user;
+ (NSString *)username;
+ (NSString *)authenticationToken;
+ (void)logout;
+ (void)loginWithUsername:(NSString *)username authenticationToken:(NSString *)authenticationToken;
+ (void)setUsername:(NSString *)username;

@end
