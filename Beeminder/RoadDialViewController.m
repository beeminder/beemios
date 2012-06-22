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

@synthesize goalRateTextField = _goalRateTextField;
@synthesize goalUnitsTextField = _goalUnitsTextField;
@synthesize goalUnitsPicker = _goalUnitsPicker;

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
    self.goalUnitsPicker.hidden = YES;
    
//    self.title = self.goalType;
//    self.goalRateTexField.text = [NSString stringWithFormat:@"%i", (int)self.goalRateStepper.value];
    
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
    [self setGoalRateTextField:nil];
    [self setGoalUnitsTextField:nil];
    [self setGoalUnitsPicker:nil];
    [super viewDidUnload];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return @"foo";
}

- (IBAction)goalRateStepperChanged {
}
@end
