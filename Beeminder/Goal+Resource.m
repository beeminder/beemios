//
//  Goal+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Resource.h"

@implementation Goal (Resource)

+ (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict
    forUserWithUsername:(NSString *)username
{
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    User *user = [User MR_findFirstByAttribute:@"username" withValue:username inContext:defaultContext];
    
    Goal *goal = [user writeToGoalWithDictionary:goalDict];
    [defaultContext save:nil];
    return goal;
}

- (void)pushToRemoteWithCompletionBlock:(CompletionBlock)completionBlock
{
    [GoalPushRequest requestForGoal:self withCompletionBlock:completionBlock];
}

- (void)pushRoadDialToRemoteWithCompletionBlock:(CompletionBlock)completionBlock
{
    [GoalPushRequest roadDialRequestForGoal:self withCompletionBlock:completionBlock];
}

- (NSString *)createURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@/goals.json", kBaseURL, kAPIPrefix, self.user.username];
}

- (NSString *)readURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json", kBaseURL, kAPIPrefix, self.user.username, self.slug];
}

- (NSString *)updateURL
{
    return [self readURL];
}

- (NSString *)deleteURL
{
    return [self readURL];
}

- (NSString *)roadDialURL
{
    return [NSString stringWithFormat:@"%@/%@/users/%@/goals/%@/dial_road.json", kBaseURL, kAPIPrefix, self.user.username, self.slug];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *key in [[self.entity attributesByName] allKeys]) {
        NSString * val = [self performSelector:NSSelectorFromString(key)];
        if (val) {
            [dict setObject:val forKey:key];
        }

    }
    return dict;
}

- (int)losedateDays
{
    int seconds = (int)[[NSDate dateWithTimeIntervalSince1970:[self.losedate doubleValue]] timeIntervalSinceNow];
    
    if (seconds > 0) {
        return seconds/(3600*24);
    }
    else {
        return -1;
    }
}

- (int)losedateHours
{
    int seconds = (int)[[NSDate dateWithTimeIntervalSince1970:[self.losedate doubleValue]] timeIntervalSinceNow];
    
    if (seconds > 0) {
        return (seconds % (3600*24))/3600;
    }
    else {
        return -1;
    }
}

- (int)losedateMinutes
{
    int seconds = (int)[[NSDate dateWithTimeIntervalSince1970:[self.losedate doubleValue]] timeIntervalSinceNow];
    
    if (seconds > 0) {
        return (seconds % 3600)/60;
    }
    else {
        return -1;
    }
}

- (int)losedateSeconds
{
    int seconds = (int)[[NSDate dateWithTimeIntervalSince1970:[self.losedate doubleValue]] timeIntervalSinceNow];
    
    if (seconds > 0) {
        return seconds % 60;
    }
    else {
        return -1;
    }
}

- (NSNumber *)panicTime
{
    return [NSNumber numberWithDouble:[self.losedate doubleValue] - [self.panic doubleValue]];
}

- (NSString *)losedateTextBrief:(BOOL)brief
{
    int seconds = (int)[[NSDate dateWithTimeIntervalSince1970:[self.losedate doubleValue]] timeIntervalSinceNow];
    
    if (seconds > 0) {
        
        int hours = (seconds % (3600*24))/3600;
        int minutes = (seconds % 3600)/60;
        int leftoverSeconds = seconds % 60;
        int days = seconds/(3600*24);
        
        if (days > 0) {
            if (brief) return [NSString stringWithFormat:@"%i days", days];
            return [NSString stringWithFormat:@"%i days, %i:%02i:%02i", days, hours, minutes,leftoverSeconds];
        }
        else {
            if (brief) return [NSString stringWithFormat:@"%i days", days];
            return [NSString stringWithFormat:@"%i:%02i:%02i", hours, minutes,leftoverSeconds];
        }
        
    }
    else if (self.goaldate && [self.goaldate doubleValue] < [[NSDate date] timeIntervalSince1970]) {
        return @"Success!";
    }
    else {
        return [NSString stringWithFormat:@"Derailed!"];
    }
}

- (UIColor *)losedateColor
{
    switch (self.losedateDays) {
        case -1:
            if ([[self losedateTextBrief:YES] isEqualToString:@"Derailed!"]) {
                return [UIColor redColor];
            }
            else {
                return [UIColor colorWithRed:81.0/255.0 green:163.0/255.0 blue:81.0/255.0 alpha:1];
            }
            break;
        case 0:
            return [UIColor redColor];
            break;
        case 1:
            return [UIColor orangeColor];
            break;
        case 2:
            return [UIColor blueColor];
            break;
        default:
            return [UIColor colorWithRed:81.0/255.0 green:163.0/255.0 blue:81.0/255.0 alpha:1];
            break;
    }
}

- (void)updateGraphImages
{
    [self updateGraphImage];
    [self updateGraphImageThumb];
}

- (void)updateGraphImage
{
    [self updateGraphImageWithCompletionBlock:nil];
}

- (void)updateGraphImageThumb
{
    [self updateGraphImageThumbWithCompletionBlock:nil];
}

- (void)updateGraphImagesWithCompletionBlock:(void (^)())block
{
    [self updateGraphImageThumbWithCompletionBlock:nil];
    [self updateGraphImageWithCompletionBlock:block];
}

- (void)updateGraphImageThumbWithCompletionBlock:(void (^)())block
{
    NSURL *url = [NSURL URLWithString:self.thumb_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        self.graph_image_thumb = image;
        if (block) block();
    }];
    [operation start];
}

- (void)updateGraphImageWithCompletionBlock:(void (^)())block
{
    NSURL *url = [NSURL URLWithString:self.graph_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        self.graph_image = image;
        if (block) block();
    }];
    [operation start];
}

@end
