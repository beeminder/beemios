//
//  RoadDialViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "RoadDialViewController.h"

@interface RoadDialViewController ()

@property (nonatomic, strong) NSArray *goalUnitsOptions;
@property (nonatomic, strong) NSArray *goalRateUnitsOptions;

@end

@implementation RoadDialViewController

@synthesize goalRateTextField = _goalRateTextField;
@synthesize goalUnitsTextField = _goalUnitsTextField;
@synthesize goalRateStepper = _goalRateStepper;
@synthesize goalRateUnitsTextField = _goalRateUnitsTextField;
@synthesize goalUnitsOptions = _goalUnitsOptions;
@synthesize goalRateUnitsOptions = _goalRateUnitsOptions;

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

    self.goalUnitsOptions = [[NSArray alloc] initWithObjects:@"times", @"minutes", @"hours", @"pounds lost", @"pounds gained", nil];
    
    UIPickerView *goalUnitsPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    goalUnitsPicker.tag = 0;
    goalUnitsPicker.delegate = self;
    goalUnitsPicker.dataSource = self;
    goalUnitsPicker.showsSelectionIndicator = YES;
    
    self.goalUnitsTextField.inputView = goalUnitsPicker;
    
    self.goalUnitsTextField.text = [self.goalUnitsOptions objectAtIndex:0];    
    
    self.goalRateUnitsOptions = [[NSArray alloc] initWithObjects:@"day", @"week", @"month", nil];
    
    UIPickerView *goalRateUnitsPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    goalRateUnitsPicker.tag = 1;
    goalRateUnitsPicker.delegate = self;
    goalRateUnitsPicker.dataSource = self;
    goalRateUnitsPicker.showsSelectionIndicator = YES;
    
    self.goalRateUnitsTextField.inputView = goalRateUnitsPicker;

    self.goalRateUnitsTextField.text = [self.goalRateUnitsOptions objectAtIndex:0];
    
    
    [self goalRateStepperChanged];

    
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
    [self setGoalRateStepper:nil];
    [self setGoalRateUnitsTextField:nil];
    [super viewDidUnload];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 0) {
        return self.goalUnitsOptions.count;
    }
    else if (pickerView.tag == 1) {
        return self.goalRateUnitsOptions.count;
    }
    return 1;
}

#pragma mark UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 0) {
        self.goalUnitsTextField.text = [self.goalUnitsOptions objectAtIndex:row];
    }
    else if (pickerView.tag == 1) {
        self.goalRateUnitsTextField.text = [self.goalRateUnitsOptions objectAtIndex:row];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 0) {
        return [self.goalUnitsOptions objectAtIndex:row];
    }
    else {
        return [self.goalRateUnitsOptions objectAtIndex:row];
    }    

}

- (IBAction)goalRateStepperChanged {
    self.goalRateTextField.text = [NSString stringWithFormat:@"%i", (int)self.goalRateStepper.value];
}


@end
