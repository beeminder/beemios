//
//  BeeminderAppDelegate.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "BeeminderAppDelegate.h"
#import <CoreData/CoreData.h>
#import "BeeminderViewController.h"
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
