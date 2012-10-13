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
    [defaultContext MR_save];
    return goal;
}

- (void)pushToRemoteWithSuccessBlock:(CompletionBlock)successBlock
{
    [GoalPushRequest requestForGoal:self withSuccessBlock:successBlock];
}

- (void)pushRoadDialToRemoteWithSuccessBlock:(CompletionBlock)successBlock
{
    [GoalPushRequest roadDialRequestForGoal:self withSuccessBlock:successBlock];
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

- (NSString *)paramString
{
    NSString *pString = [NSString stringWithFormat:@"ephem=%d&goal_type=%@&slug=%@&title=%@", [self.ephem integerValue], self.goal_type, self.slug, (__bridge NSString *)(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.title, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8))];
    
    if (self.burner) {
        pString = [pString stringByAppendingFormat:@"&burner=%@", self.burner];
    }
    
    if (self.goaldate) {
        pString = [pString stringByAppendingFormat:@"&goaldate=%f", [self.goaldate doubleValue]];
    }
    
    if (self.rate) {
        pString = [pString stringByAppendingFormat:@"&rate=%f", [self.rate doubleValue]];
    }
    
    if (self.goalval) {
        pString = [pString stringByAppendingFormat:@"&goalval=%f", [self.goalval doubleValue]];
    }
    
    if (self.initval) {
        pString = [pString stringByAppendingFormat:@"&initval=%f", [self.initval doubleValue]];
    }
    
    return pString;
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
    else if (self.goaldate && [self.goaldate doubleValue] < [[NSDate date] timeIntervalSince1970] && [self.losedate doubleValue] > [self.goaldate doubleValue]) {
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
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:300];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
        return image;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.graph_image_thumb = image;
        if (block) block();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"223");
        NSLog(@"%@", self);
        NSLog(@"%@", request.URL);
        NSLog(@"%@", error);
    }];

    [operation start];
}

- (void)updateGraphImageWithCompletionBlock:(void (^)())block
{
    NSURL *url = [NSURL URLWithString:self.graph_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:300];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
        return image;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.graph_image = image;
        if (block) block();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@", error);
    }];
    [operation start];
}

@end
