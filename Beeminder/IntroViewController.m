//
//  IntroViewController.m
//  Beeminder
//
//  Created by Andy Brett on 12/15/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

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
    self.view.backgroundColor = [BeeminderAppDelegate cloudsColor];
    UIFont *f = [UIFont fontWithName:@"Lato" size:15.0f];
    self.para1.font = f;
    self.para3.font = f;
    self.para2.font = [UIFont fontWithName:@"Lato" size:13.0f];
    self.header.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
    self.dismissButton = [BeeminderAppDelegate standardGrayButtonWith:self.dismissButton];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDismissButton:nil];
    [self setTitle:nil];
    [self setPara1:nil];
    [self setHeader:nil];
    [self setPara2:nil];
    [self setPara3:nil];
    [super viewDidUnload];
}

- (IBAction)dismissButtonPressed
{
    SplashViewController *svCon = (SplashViewController *)self.presentingViewController;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UINavigationController *newGoalNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"newGoalNavigationController"];
    
    [svCon dismissViewControllerAnimated:YES completion:^{
        [svCon presentViewController:newGoalNavigationController animated:YES completion:nil];
    }];
}

@end
