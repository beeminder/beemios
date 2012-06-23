//
//  ChooseGoalNameViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/22/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ChooseGoalNameViewController.h"

@interface ChooseGoalNameViewController ()

@end

@implementation ChooseGoalNameViewController
@synthesize goalNameTextField;
@synthesize submitButton;

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setGoalNameTextField:nil];
    [self setSubmitButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setTitle:self.goalNameTextField.text];
}
    

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    [textField resignFirstResponder];
    [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside]; //press button
    return YES;
}

@end
