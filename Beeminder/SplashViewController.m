//
//  SplashViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SplashViewController.h"
#import "BeeminderViewController.h"

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

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    if ([defaults objectForKey:@"authenticationTokenKey"]) {
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"skipToDashboard"]) {
//        UITabBarController *tabBar = (UITabBarController *)segue.destinationViewController;
//        UINavigationController *navCon = (UINavigationController *) [tabBar.viewControllers objectAtIndex:0];
//        GoalsTableViewController *goalCon = (GoalsTableViewController *)[navCon.viewControllers objectAtIndex:0];
//        
//        [goalCon setManagedObjectContext:self.managedObjectContext];
//
//    }
//    else {
//        [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
//    }
//}

@end
