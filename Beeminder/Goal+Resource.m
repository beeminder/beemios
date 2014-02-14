//
//  Goal+Resource.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Resource.h"

@implementation Goal (Resource)

+ (NSDictionary *)processGoalDictFromServer:(NSDictionary *)goalDict
{
    NSMutableDictionary *modGoalDict = [NSMutableDictionary dictionaryWithDictionary:goalDict];
    [modGoalDict setObject:[goalDict objectForKey:@"id"] forKey:@"serverId"];
    
    NSString *runits = [goalDict objectForKey:@"runits"];
    NSNumber *weeklyRate;
    if ([goalDict objectForKey:@"rate"] != (id)[NSNull null]) {
        
        if ([runits isEqualToString:@"y"]) {
            weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]/52];
        }
        else if ([runits isEqualToString:@"m"]) {
            weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]/4];
        }
        else if ([runits isEqualToString:@"d"]) {
            weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]*7];
        }
        else if ([runits isEqualToString:@"h"]) {
            weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]*7*24];
        }
        else {
            weeklyRate = [goalDict objectForKey:@"rate"];
        }
        [modGoalDict setObject:weeklyRate forKey:@"rate"];
    }
    
    return [NSDictionary dictionaryWithDictionary:modGoalDict];
}

+ (Goal *)writeToGoalWithDictionary:(NSDictionary *)goalDict
    forUserWithUsername:(NSString *)username
{
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    User *user = [User MR_findFirstByAttribute:@"username" withValue:username inContext:defaultContext];
    
    Goal *goal = [user writeToGoalWithDictionary:goalDict];
    [defaultContext MR_saveToPersistentStoreAndWait];
    return goal;
}

- (void)pushToRemoteWithAdditionalParams:(NSDictionary *)additionalParams successBlock:(CompletionBlock)successBlock
{
    [GoalPushRequest requestForGoal:self additionalParams:additionalParams withSuccessBlock:successBlock];
}

- (NSString *)readURL
{
    return [NSString stringWithFormat:@"/%@/users/me/goals/%@.json", kAPIPrefix, self.slug];
}

- (NSString *)updateURL
{
    return [self readURL];
}

- (NSString *)deleteURL
{
    return [self readURL];
}

- (NSDictionary *)paramsDict
{
    NSMutableDictionary *pDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.goal_type, @"goal_type", self.slug, @"slug", [BeeminderAppDelegate encodedString:self.title], @"title", nil];

    if (self.burner) {
        [pDict setObject:self.burner forKey:@"burner"];
    }
    
    if (self.goaldate) {
        [pDict setObject:self.goaldate forKey:@"goaldate"];
    }
    
    if (self.rate) {
        [pDict setObject:self.rate forKey:@"rate"];
    }
    
    if (self.goalval) {
        [pDict setObject:self.goalval forKey:@"goalval"];
    }
    
    if (self.initval) {
        [pDict setObject:self.initval forKey:@"initval"];
    }
    
    if (self.fitbit) {
        [pDict setObject:@"true" forKey:@"fitbit"];
        [pDict setObject:self.fitbit_field forKey:@"fitbit_field"];
    }
    
    return [NSDictionary dictionaryWithDictionary:pDict];
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

- (NSString *)bareMinTodayString
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"today|within 0 days" options:0 error:nil];
    if (([self.goal_type isEqualToString:kHustlerPrivate] ||
         [self.goal_type isEqualToString:kBikerPrivate]) &&
          self.limsum && [self.limsum length] > 0 &&
         [regex numberOfMatchesInString:self.limsum options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, self.limsum.length)] > 0) {
        
        return [self.limsum stringByReplacingOccurrencesOfString:@"within 0 days" withString:@"today"];
    }
    else {
        return @"";
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
            if (brief) return [NSString stringWithFormat:@"%i %@", days, days == 1 ? @"day" : @"days"];
            return [NSString stringWithFormat:@"%i %@, %i:%02i:%02i", days, days == 1 ? @"day" : @"days", hours, minutes,leftoverSeconds];
        }
        else { // days = 0
            if (brief) {
                if ([self bareMinTodayString].length > 0) {
                    return [self bareMinTodayString];
                }
                return [NSString stringWithFormat:@"%i %@", days, days == 1 ? @"day" : @"days"];
            }
            return [NSString stringWithFormat:@"%i:%02i:%02i", hours, minutes,leftoverSeconds];
        }
        
    }
    else if ([self.won boolValue]) {
        return @"Success!";
    }
    else {
        return [NSString stringWithFormat:@"Derailed!"];
    }
}

- (BOOL)canAcceptData
{
    double grace = 3*3600;
    return ![self.frozen boolValue] || ([self.losedate doubleValue] + grace > [[NSDate date] timeIntervalSince1970]);
}

- (BOOL)isDerailed
{
    return [[self losedateTextBrief:YES] isEqualToString:@"Derailed!"];
}

- (UIColor *)losedateColor
{
    switch ([self losedateDays]) {
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
    if (!self.thumb_url) return;
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSLog(@"%@", self.thumb_url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.thumb_url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    [[delegate.imageOperationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.graph_image_thumb = responseObject;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        if (block) block();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //bar
    }] start];
}

- (void)updateGraphImageWithCompletionBlock:(void (^)())block
{
    if (!self.graph_url) return;
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.graph_url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    [[delegate.imageOperationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.graph_image = responseObject;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        if (block) block();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //bar
    }] start];
}

@end
