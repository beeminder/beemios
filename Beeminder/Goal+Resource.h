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

+ (NSDictionary *)processGoalDictFromServer:(NSDictionary *)goalDict;
+ (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict forUserWithUsername:(NSString *)username;

- (void)pushToRemoteWithAdditionalParams:(NSDictionary*)additionalParams successBlock:(CompletionBlock)successBlock;
- (NSString *)createURL;
- (NSString *)readURL;
- (NSString *)updateURL;
- (NSString *)deleteURL;
- (NSString *)roadDialURL;
- (NSString *)paramString;
- (NSDictionary *)paramsDict;
- (NSString *)losedateTextBrief:(BOOL)brief;
- (NSNumber *)panicTime;
- (int)losedateDays;
- (int)losedateHours;
- (int)losedateMinutes;
- (int)losedateSeconds;
- (UIColor *)losedateColor;
- (void)updateGraphImages;
- (void)updateGraphImage;
- (void)updateGraphImageThumb;
- (void)updateGraphImagesWithCompletionBlock:(void (^) ())block;
- (void)updateGraphImageWithCompletionBlock:(void (^) ())block;
- (void)updateGraphImageThumbWithCompletionBlock:(void (^) ())block;
- (BOOL)isDerailed;
- (BOOL)canAcceptData;

@end
