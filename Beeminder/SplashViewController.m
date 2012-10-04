//
//  SplashViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SplashViewController.h"
#import "BeeminderViewController.h"
#import "User+Resource.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize startTrackingButton;
@synthesize signInButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([ABCurrentUser accessToken] && [ABCurrentUser username]) {
        [[self.navigationController navigationBar] setHidden:YES];
        [self performSegueWithIdentifier:@"skipToDashboard" sender:self];
    }
    
    [GradientViews addGradient:self.view withColor:[UIColor colorWithRed:1.0 green:203.0/255.0f blue:8.0f/255.0 alpha:1.0] startAtTop:YES cornerRadius:0.0f borderColor:nil];
    self.startTrackingButton = [BeeminderAppDelegate standardGrayButtonWith:self.startTrackingButton];
    self.signInButton = [BeeminderAppDelegate standardGrayButtonWith:self.signInButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![ABCurrentUser username]) {
        NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
        NSMutableString *s = [NSMutableString stringWithCapacity:20];
        for (NSUInteger i = 0U; i < 20; i++) {
            u_int32_t r = arc4random() % [alphabet length];
            unichar c = [alphabet characterAtIndex:r];
            [s appendFormat:@"%C", c];
        }
        
        [ABCurrentUser setUsername:s];
        
        NSDictionary *userDict = [NSDictionary dictionaryWithObject:s forKey:@"username"];
        
        [User writeToUserWithDictionary:userDict];
    }
}

- (void)viewDidUnload
{
    [self setStartTrackingButton:nil];
    [self setSignInButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end
