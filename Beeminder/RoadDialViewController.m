//
//  RoadDialViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "RoadDialViewController.h"

@interface RoadDialViewController ()

@property (nonatomic, strong) NSArray *goalRateNumeratorUnitsOptions;
@property (nonatomic, strong) NSArray *goalRateDenominatorUnitsOptions;

- (NSString *) goalStatement;

@end

@implementation RoadDialViewController

@synthesize pickerToolbar = _pickerToolbar;
@synthesize goalStatementLabel = _goalStatementLabel;
@synthesize goalRateNumerator = _goalRateNumerator;
@synthesize goalRateNumeratorUnits = _goalRateNumeratorUnits;
@synthesize goalRateDenominatorUnits = _goalRateDenominatorUnits;
@synthesize goalRateNumeratorUnitsOptions = _goalRateNumeratorUnitsOptions;
@synthesize goalRateDenominatorUnitsOptions = _goalRateDenominatorUnitsOptions;

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

    self.goalRateNumeratorUnitsOptions = [[NSArray alloc] initWithObjects:@"times", @"minutes", @"hours", @"lbs lost", @"lbs gained", nil];   
    
    self.goalRateDenominatorUnitsOptions = [[NSArray alloc] initWithObjects:@"day", @"week", @"month", nil];
    self.goalStatementLabel.text = @"Default goal";
    
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
    [self setPickerToolbar:nil];
    [self setGoalStatementLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // save goal
    [segue.destinationViewController setTitle:self.title];
}

- (NSString *) goalStatement
{
    return [NSString stringWithFormat:@"%i %@ per %@", self.goalRateNumerator, self.goalRateNumeratorUnits, self.goalRateDenominatorUnits];
}

#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView 
{
    if (pickerView.tag == 0) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component 
{
    if (pickerView.tag == 0) {
        if (component == 0) {
            return 1000;
        }
        else {
            return self.goalRateNumeratorUnitsOptions.count;
        }
    }
    else {
        return self.goalRateDenominatorUnitsOptions.count;
    }
}

#pragma mark UIPickerViewDelegate methods

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component 
{
    if (pickerView.tag == 0) {
        if (component == 0) {
            return 50.0;
        }
        else {
            return 100.0;
        }
    }
    else {
        return 100.0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component 
{
    if (pickerView.tag == 0) {
        self.goalRateNumerator = [pickerView selectedRowInComponent:0];
        self.goalRateNumeratorUnits = [self.goalRateNumeratorUnitsOptions objectAtIndex:[pickerView selectedRowInComponent:1]];
    }
    else {
        self.goalRateDenominatorUnits = [self.goalRateDenominatorUnitsOptions objectAtIndex:[pickerView selectedRowInComponent:0]];
    }
    self.goalStatementLabel.text = self.goalStatement;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component 
{
    if (pickerView.tag == 0) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%i", row];
        }
        else {
            return [self.goalRateNumeratorUnitsOptions objectAtIndex:row];
        }
    }
    else {
        return [self.goalRateDenominatorUnitsOptions objectAtIndex:row];
    }
}

@end
