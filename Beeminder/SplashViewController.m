//
//  SplashViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SplashViewController.h"
#import "BeeminderViewController.h"
#import "User+Create.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

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
    
    NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    if (!username) {
        // random string for the temporary username.
        NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
        NSMutableString *s = [NSMutableString stringWithCapacity:20];
        for (NSUInteger i = 0U; i < 20; i++) {
            u_int32_t r = arc4random() % [alphabet length];
            unichar c = [alphabet characterAtIndex:r];
            [s appendFormat:@"%C", c];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:s forKey:@"username"];
        
        NSDictionary *userDict = [NSDictionary dictionaryWithObject:s forKey:@"username"];
        
        [User userWithUserDict:userDict withContext:[self managedObjectContext]];
    }
    
    else if (authToken) {
        [[self.navigationController navigationBar] setHidden:YES];
        [self performSegueWithIdentifier:@"skipToDashboard" sender:self];
    }
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
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
