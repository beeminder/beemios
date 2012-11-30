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
    return [NSString stringWithFormat:@"%@/%@/users/me/goals.json", kBaseURL, kAPIPrefix];
}

- (NSString *)readURL
{
    return [NSString stringWithFormat:@"%@/%@/users/me/goals/%@.json", kBaseURL, kAPIPrefix, self.slug];
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
    return [NSString stringWithFormat:@"%@/%@/users/me/goals/%@/dial_road.json", kBaseURL, kAPIPrefix, self.slug];
}

- (NSString *)paramString
{
    NSString *pString = [NSString stringWithFormat:@"ephem=%d&goal_type=%@&slug=%@&title=%@", [self.ephem integerValue], self.goal_type, self.slug, AFURLEncodedStringFromStringWithEncoding(self.title, NSUTF8StringEncoding)];    
    
    if (self.burner) {
        pString = [pString stringByAppendingFormat:@"&burner=%@", self.burner];
    }
    
    if (self.goaldate) {
        pString = [pString stringByAppendingFormat:@"&goaldate=%f", [self.goaldate doubleValue]];
    }
    
    if (self.rate) {
        pString = [pString stringByAppendingFormat:@"&rate=%g", [self.rate doubleValue]];
    }
    
    if (self.goalval) {
        pString = [pString stringByAppendingFormat:@"&goalval=%g", [self.goalval doubleValue]];
    }
    
    if (self.initval) {
        pString = [pString stringByAppendingFormat:@"&initval=%g", [self.initval doubleValue]];
    }
    
    if (self.fitbit) {
        pString = [pString stringByAppendingFormat:@"&fitbit=true&fitbit_field=%@", self.fitbit_field];
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
    else if (self.won) {
        return @"Success!";
    }
    else {
        return [NSString stringWithFormat:@"Derailed!"];
    }
}

- (BOOL)won
{
    return self.goaldate && [self.goaldate doubleValue] < [[NSDate date] timeIntervalSince1970] && [self.losedate doubleValue] > [self.goaldate doubleValue];
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
    NSURL *url = [NSURL URLWithString:self.thumb_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:300];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
        return image;
    } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.graph_image_thumb = image;
        if (block) block();
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
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
