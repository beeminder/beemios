//
//  Goal+Resource.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal.h"
#import "User+Resource.h"
#import "GoalPushRequest.h"

@interface Goal (Resource)

+ (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict
                forUserWithUsername:(NSString *)username;

- (void)pushToRemoteWithCompletionBlock:(CompletionBlock)completionBlock;
- (NSString *)createURL;
- (NSString *)readURL;
- (NSString *)updateURL;
- (NSString *)deleteURL;
- (NSDictionary *)dictionary;
- (NSString *)countdownText;
- (int)countdownDays;
- (int)countdownHours;
- (int)countdownMinutes;
- (int)countdownSeconds;
- (UIColor *)countdownColor;

@end
