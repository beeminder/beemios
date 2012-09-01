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

@end

@implementation RoadDialViewController

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
    self.pickerOffset = 20;
    self.fatLoserIndex = 3;

    self.goalRateNumeratorUnitsOptions = [[NSArray alloc] initWithObjects:@"times", @"minutes", @"hours", @"pounds", nil];   
    
    self.goalRateDenominatorUnitsOptions = [[NSArray alloc] initWithObjects:@"day", @"week", @"month", nil];
    self.goalRateNumeratorIndex =  self.pickerOffset + 5;
    self.goalRateNumeratorUnits = @"times";
    self.goalRateDenominatorUnits = @"week";
    [self.goalRateNumeratorPickerView selectRow:self.pickerOffset inComponent:0 animated:YES];
    [self.goalRateNumeratorPickerView selectRow:0 inComponent:1 animated:YES];
    [self.goalRateNumeratorPickerView selectRow:self.pickerOffset + 5 inComponent:0 animated:YES];
    [self.goalRateDenominatorPickerView selectRow:1 inComponent:0 animated:YES];
    self.goalRateNumeratorLabel.hidden = YES;
    self.goalRateNumeratorUnitsLabel.hidden = YES;
    self.goalRateDenominatorLabel.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([self.goalObject.gtype isEqualToString:@"fatloser"]) {
        [self.goalRateNumeratorPickerView selectRow:3 inComponent:1 animated:YES];
    }
    else if ([self.goalObject.gtype isEqualToString:@"hustler"]) {
        [self.goalRateNumeratorPickerView selectRow:0 inComponent:1 animated:YES];
    }
    else if ([self.goalObject.gtype isEqualToString:@"biker"]) {
        // ask for today's value
    }
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
    [self setGoalRateNumeratorPickerView:nil];
    [self setGoalRateDenominatorPickerView:nil];
    [self setGoalRateNumeratorLabel:nil];
    [self setGoalRateDenominatorLabel:nil];
    [self setGoalRateNumeratorUnitsLabel:nil];
    [super viewDidUnload];
}

- (NSInteger)goalRateNumeratorWithOffset
{
    return self.goalRateNumeratorIndex - self.pickerOffset;
}

- (NSNumber *)weeklyRate {
    if (self.goalObject.goaldate && self.goalObject.goalval) {
        return nil;
    }
    if ([self.goalRateDenominatorUnits isEqualToString:@"week"]) {
        return [NSNumber numberWithInt:[self goalRateNumeratorWithOffset]];
    }
    else if ([self.goalRateDenominatorUnits isEqualToString:@"day"]) {
        return [NSNumber numberWithInt: [self goalRateNumeratorWithOffset]*7];
    }
    else { // "month"
        return [NSNumber numberWithFloat:[self goalRateNumeratorWithOffset]/4.3f];
    }
}

- (IBAction)nextButtonPressed:(UIBarButtonItem *)sender
{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:365*24*3600];
    NSNumber *timestamp = [NSNumber numberWithDouble:[date timeIntervalSince1970]];

    self.goalObject.rate = [self weeklyRate];
    self.goalObject.goaldate = timestamp;
    self.goalObject.units = self.goalRateNumeratorUnits;
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    if ([ABCurrentUser authenticationToken]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Saving...";
        CompletionBlock completionBlock = ^() {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self performSegueWithIdentifier:@"segueToDashboard" sender:self];
        };
        [self.goalObject pushToRemoteWithCompletionBlock:completionBlock];

    }
    else {
        [self performSegueWithIdentifier:@"segueToSignup" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToDashboard"]) {
        [[self.navigationController navigationBar] setHidden:YES];
    }
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
        self.goalRateNumeratorIndex = [pickerView selectedRowInComponent:0];
        self.goalRateNumeratorUnits = [self.goalRateNumeratorUnitsOptions objectAtIndex:[pickerView selectedRowInComponent:1]];
        if (row == self.fatLoserIndex) {
            self.goalObject.gtype = @"fatloser";
        }
    }
    else {
        self.goalRateDenominatorUnits = [self.goalRateDenominatorUnitsOptions objectAtIndex:[pickerView selectedRowInComponent:0]];
    }
    self.goalObject.goalval = nil;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component 
{ 
    if (pickerView.tag == 0) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%i", row - 20];
        }
        else {
            return [self.goalRateNumeratorUnitsOptions objectAtIndex:row];
        }
    }
    else {
        return [self.goalRateDenominatorUnitsOptions objectAtIndex:row];
    }
}

- (IBAction)showChooseGoalType:(UIBarButtonItem *)sender
{
    ChooseGoalTypeViewController *chooseGTController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"chooseGoalTypeViewController"];
    chooseGTController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.goalObject.rate = [self weeklyRate];
    chooseGTController.goalObject = self.goalObject;
    chooseGTController.rdvCon = self;
    [self presentViewController:chooseGTController animated:YES completion:nil];
}

- (IBAction)showAdvanced:(UIBarButtonItem *)sender
{
    AdvancedRoalDialViewController *advCon = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"advancedRoadDialViewController"];
    
    advCon.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.goalObject.rate = [self weeklyRate];
    if (!self.goalObject.goaldate) {
        self.goalObject.goaldate = [NSNumber numberWithDouble:[[NSDate dateWithTimeIntervalSince1970: [[NSDate date] timeIntervalSince1970] + 365*24*3600] timeIntervalSince1970]];
    }
    advCon.goalObject = self.goalObject;
    advCon.rdvCon = self;
    [self presentViewController:advCon animated:YES completion:nil];
    
}

- (void)resetRoadDial
{
    self.goalObject.rate = [NSNumber numberWithInt:0];
    self.goalObject.units = @"times";
    self.goalRateNumeratorLabel.hidden = YES;
    self.goalRateNumeratorUnitsLabel.hidden = YES;
    self.goalRateDenominatorLabel.hidden = YES;
    self.goalRateDenominatorPickerView.hidden = NO;
    self.goalRateNumeratorPickerView.hidden = NO;
}

- (void)modalDidSaveRoadDial
{
    if (self.goalObject.rate && !self.goalRateNumeratorPickerView.hidden) {
        [self.goalRateNumeratorPickerView selectRow:[self.goalObject.rate integerValue] + self.pickerOffset inComponent:0 animated:YES];
    }
    else {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"goal = %@", self.goalObject];
        Datapoint *datapoint = [Datapoint MR_findFirstWithPredicate:pred sortedBy:@"timestamp" ascending:NO];
        
        double diff = [self.goalObject.goalval doubleValue] - [datapoint.value doubleValue];
        
        double interval = [self.goalObject.goaldate doubleValue] - [[NSDate date] timeIntervalSince1970];
        
        double rate = diff*3600*7*24/interval;
        
        self.goalRateNumeratorLabel.text = [NSString stringWithFormat:@"%.02f", rate];
        self.goalRateNumeratorLabel.hidden = NO;
        
        self.goalRateNumeratorUnitsLabel.text = [self pickerView:self.goalRateNumeratorPickerView titleForRow:[self.goalRateNumeratorPickerView selectedRowInComponent:1] forComponent:1];
        self.goalRateNumeratorUnitsLabel.hidden = NO;
        
        self.goalRateDenominatorLabel.text = [self pickerView:self.goalRateDenominatorPickerView titleForRow:[self.goalRateDenominatorPickerView selectedRowInComponent:0] forComponent:0];
        self.goalRateDenominatorLabel.hidden = NO;
        
        self.goalRateDenominatorPickerView.hidden = YES;
        self.goalRateNumeratorPickerView.hidden = YES;

    }

    [self.goalRateDenominatorPickerView selectRow:1 inComponent:0 animated:YES];

}


@end
