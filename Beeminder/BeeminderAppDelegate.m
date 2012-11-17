//
//  BeeminderAppDelegate.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "BeeminderAppDelegate.h"
#import <CoreData/CoreData.h>
#import "CoreData+MagicalRecord.h"

@implementation BeeminderAppDelegate

+ (UIButton *)standardGrayButtonWith:(UIButton *)button
{
    button.backgroundColor = [BeeminderAppDelegate grayButtonColor];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    button.layer.cornerRadius = 5.0f;

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    return button;
}

+ (UIColor *)grayButtonColor
{
    return [UIColor colorWithRed:184.0f/255.0 green:184.0f/255.0 blue:184.0f/255.0 alpha:1.0];
}

- (Goal *)sessionGoal
{
    if (!_sessionGoal) {
        self.sessionGoal = [Goal MR_createEntity];
    }
    return _sessionGoal;
}

+ (Goal *)sharedSessionGoal
{
    BeeminderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return delegate.sessionGoal;
}

+ (void)clearSessionGoal
{
    BeeminderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.sessionGoal = nil;
}

+ (NSString *)slugFromTitle:(NSString *)title
{
    NSRegularExpression *whitespaceRegex = [NSRegularExpression regularExpressionWithPattern:@"[\\s]" options:0 error:nil];
    
    NSString *noSpaces = [whitespaceRegex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, title.length) withTemplate:@"-"];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\-\\_]" options:0 error:nil];
    
    NSString *slug = [regex stringByReplacingMatchesInString:noSpaces options:0 range:NSMakeRange(0, noSpaces.length) withTemplate:@""];
    
    return slug;
}

+ (NSDictionary *)goalTypesInfo
{
    NSDictionary *fatLoser = [NSDictionary dictionaryWithObjectsAndKeys:kFatloserPrivate, kPrivateNameKey, kFatloserPublic, kPublicNameKey, kFatloserDetails, kDetailsKey, kFatloserInstructions, kInstructionsKey, [NSNumber numberWithInt:3], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *hustler = [NSDictionary dictionaryWithObjectsAndKeys:kHustlerPrivate, kPrivateNameKey, kHustlerPublic, kPublicNameKey, kHustlerDetails, kDetailsKey, kHustlerInstructions, kInstructionsKey, [NSNumber numberWithInt:1], kSortPriorityKey, [NSNumber numberWithBool:YES], kKyoomKey, nil];
    
    NSDictionary *biker = [NSDictionary dictionaryWithObjectsAndKeys:kBikerPrivate, kPrivateNameKey, kBikerPublic, kPublicNameKey, kBikerDetails, kDetailsKey, kBikerInstructions, kInstructionsKey, [NSNumber numberWithInt:2], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *inboxer = [NSDictionary dictionaryWithObjectsAndKeys:kInboxerPrivate, kPrivateNameKey, kInboxerPublic, kPublicNameKey, kInboxerDetails, kDetailsKey, kBikerInstructions, kInstructionsKey, [NSNumber numberWithInt:4], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *custom = [NSDictionary dictionaryWithObjectsAndKeys:kCustomPrivate, kPrivateNameKey, kCustomPublic, kPublicNameKey, kCustomDetails, kDetailsKey, kCustomInstructions, kInstructionsKey, [NSNumber numberWithInt:6], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *drinker = [NSDictionary dictionaryWithObjectsAndKeys:kDrinkerPrivate, kPrivateNameKey, kDrinkerPublic, kPublicNameKey, kDrinkerDetails, kDetailsKey, kDrinkerInstructions, kInstructionsKey, [NSNumber numberWithInt:5], kSortPriorityKey, [NSNumber numberWithBool:YES], kKyoomKey, nil];
    
    NSDictionary *fitbit = [NSDictionary dictionaryWithObjectsAndKeys:kFitbitPrivate, kPrivateNameKey, kFitbitPublic, kPublicNameKey, kFitbitDetails, kDetailsKey, kFitbitInstructions, kInstructionsKey, [NSNumber numberWithInt:6], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:fatLoser, kFatloserPrivate, hustler, kHustlerPrivate, biker, kBikerPrivate, inboxer, kInboxerPrivate, drinker, kDrinkerPrivate, fitbit, kFitbitPrivate, custom, kCustomPrivate, nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [MagicalRecord setupCoreDataStack];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
