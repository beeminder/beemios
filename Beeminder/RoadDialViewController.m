//
//  RoadDialViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "RoadDialViewController.h"

@interface RoadDialViewController ()

@end

@implementation RoadDialViewController

@synthesize goalType = _goalType;
@synthesize introLabel = _introLabel;
@synthesize currentWeight = _currentWeight;
@synthesize goalRateStepper = _goalRateStepper;
@synthesize goalRateLabel = _goalRateLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.goalType;
    self.goalRateLabel.text = [NSString stringWithFormat:@"%i", (int)self.goalRateStepper.value];
    
    
    if (![self.goalType isEqualToString:@"Lose Weight"]) {
       [self.currentWeight removeFromSuperview];
    }
    self.introLabel.text = @"Do More Text";
    
    // TODO: store these in Core Data
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setIntroLabel:nil];
    [self setCurrentWeight:nil];
    [self setGoalRateStepper:nil];
    [self setGoalRateLabel:nil];
    [super viewDidUnload];
}

- (IBAction)goalRateChanged:(UIStepper *)sender {
        
    self.goalRateLabel.text = [NSString stringWithFormat:@"%i", (int)sender.value];
}

@end
