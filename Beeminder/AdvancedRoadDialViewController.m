//
//  AdvancedRoalDialViewController.m
//  Beeminder
//
//  Created by Andy Brett on 7/25/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "AdvancedRoadDialViewController.h"
#import "RoadDialViewController.h"
#import "MainTabBarViewController.h"
#import "NewGoalViewController.h"

@interface AdvancedRoalDialViewController ()

@end

@implementation AdvancedRoalDialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *gType = self.goalObject.goal_type;
    if ([[[[BeeminderAppDelegate goalTypesInfo] objectForKey:gType] objectForKey:kKyoomKey] boolValue]) {
        self.goalValLabel.text = @"Goal total";
    }
    else {
        self.goalValLabel.text = @"Value";
    }

    self.switchCollection = [[NSMutableArray alloc] init];
    if ([self.presentingViewController isMemberOfClass:[NewGoalViewController class]]) {
        self.delayLabel.hidden = YES;
    }
    self.goalDateSwitch = [[DCRoundSwitch alloc] init];
    self.goalDateSwitch.onText = @"EDIT";
    self.goalDateSwitch.offText = @"INFER";
    CGRect defaultFrame = self.goalDateSwitch.frame;
    self.goalDateSwitch.frame = CGRectMake(15, 160, defaultFrame.size.width + 12, defaultFrame.size.height);
    self.goalDateSwitch.tag = 0;
    [self.view addSubview:self.goalDateSwitch];
    [self.switchCollection addObject:self.goalDateSwitch];
    
    self.goalValueSwitch = [[DCRoundSwitch alloc] init];
    self.goalValueSwitch.onText = @"EDIT";
    self.goalValueSwitch.offText = @"INFER";
    self.goalValueSwitch.frame = CGRectMake(115, 160, defaultFrame.size.width + 12, defaultFrame.size.height);
    self.goalValueSwitch.tag = 1;
    [self.view addSubview:self.goalValueSwitch];
    [self.switchCollection addObject:self.goalValueSwitch];
    
    self.rateSwitch = [[DCRoundSwitch alloc] init];
    self.rateSwitch.onText = @"EDIT";
    self.rateSwitch.offText = @"INFER";
    self.rateSwitch.frame = CGRectMake(215, 160, defaultFrame.size.width + 12, defaultFrame.size.height);
    self.rateSwitch.tag = 2;
    [self.view addSubview:self.rateSwitch];
    [self.switchCollection addObject:self.rateSwitch];    
    
    NSComparator compareTags = ^(id a, id b) { return [a tag] - [b tag]; };

    self.textFieldCollection = [self.textFieldCollection sortedArrayUsingComparator:compareTags];
    self.switchCollection = [NSMutableArray arrayWithArray:[self.switchCollection sortedArrayUsingComparator:compareTags]];
    
    if (!self.goalObject) {
        self.goalObject = [BeeminderAppDelegate sharedSessionGoal];
    }
    
    if (self.goalObject.goalval && self.goalObject.rate && self.goalObject.goaldate) {
        NSLog(@"Should not have all three dial params set.");
    }
    
    if (!self.goalObject.goalval && !self.goalObject.rate && !self.goalObject.goaldate) {
        NSLog(@"Zero dial params set");
        self.goalObject.rate = [NSNumber numberWithDouble:0];
        self.goalObject.goaldate = [NSNumber numberWithDouble:[[NSDate dateWithTimeIntervalSinceNow:365*24*3600] timeIntervalSince1970]];
    }

    if (self.goalObject.goalval) {
        [self enableTextFieldAtIndex:[self.switchCollection indexOfObject:self.goalValueSwitch]];
        [self.goalValueSwitch setOn:YES animated:NO ignoreControlEvents:YES];
        self.goalValueTextField.text = [NSString stringWithFormat:[self stringFormatForValue:[self.goalObject.goalval doubleValue]], [self.goalObject.goalval doubleValue]];
        [self.goalValueTextField becomeFirstResponder];
    }
    else {
        [self disableTextFieldAtIndex:[self.switchCollection indexOfObject:self.goalValueSwitch]];
        [self.goalValueSwitch setOn:NO animated:NO ignoreControlEvents:YES];
    }
    
    if (self.goalObject.rate) {
        self.rateTextField.text = [NSString stringWithFormat:[self stringFormatForValue:[self.goalObject.rate doubleValue]], [self.goalObject.rate doubleValue]];
        [self enableTextFieldAtIndex:[self.switchCollection indexOfObject:self.rateSwitch]];
        [self.rateSwitch setOn:YES animated:NO ignoreControlEvents:YES];
        [self.rateTextField becomeFirstResponder];
    }
    else {
        [self disableTextFieldAtIndex:[self.switchCollection indexOfObject:self.rateSwitch]];
        [self.rateSwitch setOn:NO animated:NO ignoreControlEvents:YES];
    }
    
    if (self.goalObject.goaldate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.goalObject.goaldate doubleValue]];
        self.goalDateTextField.text = [formatter stringFromDate:date];
        self.datePicker.date = date;
        [self enableTextFieldAtIndex:[self.switchCollection indexOfObject:self.goalDateSwitch]];
        [self.goalDateSwitch setOn:YES animated:NO ignoreControlEvents:YES];
        [self.goalDateTextField becomeFirstResponder];
    }
    else {
        [self disableTextFieldAtIndex:[self.switchCollection indexOfObject:self.goalDateSwitch]];
        [self.goalDateSwitch setOn:NO animated:NO ignoreControlEvents:YES];
    }
    
    self.goalDateTextField.inputView = self.datePicker;
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970: [[NSDate date] timeIntervalSince1970] + 7*24*3600];

    self.rateTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.goalValueTextField.keyboardType = UIKeyboardTypeDecimalPad;
    [self recalculateValues];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.goalValueSwitch addTarget:nil action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.goalDateSwitch addTarget:nil action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.rateSwitch addTarget:nil action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)showValuePicker
{
    self.valuePickerView.hidden = NO;
    self.datePicker.hidden = YES;
}

- (void)showDatePicker
{
    self.valuePickerView.hidden = YES;
    self.datePicker.hidden = NO;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    int count;
    if (self.valuePickerTextField == self.goalValueTextField) {
        count = [self.goalValueTextField.text length];
        if ([self.goalValueTextField.text rangeOfString:@"."].location != NSNotFound) {
            count--;
        }
        if ([self.goalValueTextField.text rangeOfString:@"-"].location != NSNotFound) {
            count--;
        }
    }
    else {
        count = [self.rateTextField.text length];
        if ([self.rateTextField.text rangeOfString:@"."].location != NSNotFound) {
            count--;
        }
        if ([self.rateTextField.text rangeOfString:@"-"].location != NSNotFound) {
            count--;
        }
    }
    return MAX(count, 2);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.valuePickerTextField == self.goalValueTextField) {
        [self setGoalValueTextFieldTextWithDouble:[self pickerViewValue]];
    }
    else {
        [self setRateTextFieldTextWithDouble:[self pickerViewValue]];
    }
    
    if (self.valuePickerView.numberOfComponents > 7) {
        self.valuePickerView.hidden = YES;
        [self.valuePickerTextField becomeFirstResponder];
    }

    [self.valuePickerView reloadAllComponents];
    [self setValuePickerValue];    
    [self updatePickerMagnitude];

    [self recalculateValues];
}

- (void)updatePickerMagnitude
{
    if (self.valuePickerTextField == self.goalValueTextField) {
        self.pickerViewMagnitude = MAX(0, floor(log10(ABS([self valFromForm]))));
    }
    else {
        self.pickerViewMagnitude = MAX(0, floor(log10(ABS([self rateFromForm]))));
    }
}

- (double)pickerViewValue
{
    int i = 0;
    double val = 0;
    BOOL neg = [self.valuePickerView selectedRowInComponent:0] < 10;
    double componentVal;
    while (i < self.valuePickerView.numberOfComponents) {
        int offset = i == 0 ? 10 : 0;

        componentVal = [self.valuePickerView selectedRowInComponent:i] - offset;
        val += ABS(componentVal*pow(10, self.pickerViewMagnitude - i));
        i++;
    }
    
    return neg ? -1*ABS(val) : val;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 21;
    }
    else {
        return 10;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label;
    float width = 320.0f/self.valuePickerView.numberOfComponents - 20.0f;
    
    if (component == 0) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 37)];
        label.text = [NSString stringWithFormat:@"%i", row - 10];
    }
    else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 37)];
        label.text = [NSString stringWithFormat:@"%i", row];
    }
    if (component == self.pickerViewMagnitude) {
        label.text = [label.text stringByAppendingString:@"."];
    }
        
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:22.0f];
    return label;
}

- (IBAction)recalculateValues
{
    int offSwitchIndex = [self offSwitchIndexExcludingIndex:-1];
    
    if ([self.switchCollection indexOfObject:self.rateSwitch] == offSwitchIndex) {
        [self setRateTextFieldTextFromForm];
    }
    else if ([self.switchCollection indexOfObject:self.goalValueSwitch] == offSwitchIndex) {
        [self setGoalValueTextFieldTextFromForm];
    }
    else {
        [self setGoalDateDatePickerDateFromForm];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setGoalDateSwitch:nil];
    [self setRateSwitch:nil];
    [self setGoalValueSwitch:nil];
    [self setDatePicker:nil];
    [self setGoalDateTextField:nil];
    [self setRateTextField:nil];
    [self setGoalValueTextField:nil];
    [self setDismissToolbar:nil];
    [self setSwitchCollection:nil];
    [self setTextFieldCollection:nil];
    [self setDelayLabel:nil];
    [self setGoalValLabel:nil];
    [self setValuePickerView:nil];
    [super viewDidUnload];
}

- (void)setGoalValueTextFieldTextFromForm
{
    NSDate *date = [self dateFromForm];
    
    NSTimeInterval interval = [date timeIntervalSinceNow];
    
    double weeks = interval/(3600*24*7);
    
    double rate = [self rateFromForm];
    
    double diff = weeks*rate;

    double goalVal = [self currentValue] + diff;
    
    self.goalValueTextField.text = [NSString stringWithFormat:@"%.0f", goalVal];
}

- (void)setGoalDateDatePickerDateFromForm
{
    double goalVal = [self valFromForm];
    double rate = [self rateFromForm];
    double interval = (3600*24*7)*goalVal/rate;
    
    NSDate *gDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    self.goalDateTextField.text = [formatter stringFromDate:gDate];
    self.datePicker.date = gDate;
}

- (NSString *)stringFormatForValue:(double)value
{
    if (ABS(value) >= 100) {
        return @"%.f";
    }
    return @"%.2f";
}

- (void)setRateTextFieldTextFromForm
{
    NSDate *date = [self dateFromForm];
    
    NSTimeInterval interval = [date timeIntervalSinceNow];

    double diff = [self valFromForm] - [self currentValue];
    
    double rate = diff*3600*7*24/interval;

    self.rateTextField.text = [NSString stringWithFormat:[self stringFormatForValue:rate], rate];
}

- (void)setGoalValueTextFieldTextFromGoalObject
{
    [self setGoalValueTextFieldTextWithDouble:[self.goalObject.goalval doubleValue]];
}

- (void)setGoalValueTextFieldTextWithDouble:(double)goalValue
{
    self.goalValueTextField.text = [NSString stringWithFormat:[self stringFormatForValue:goalValue], goalValue];
}

- (void)setRateTextFieldTextFromGoalObject
{
    [self setRateTextFieldTextWithDouble:[self.goalObject.rate doubleValue]];
}

- (void)setRateTextFieldTextWithDouble:(double)rate
{
    self.rateTextField.text = [NSString stringWithFormat:[self stringFormatForValue:rate], rate];
}

- (void)setValuePickerValue
{
    if (self.valuePickerTextField == self.goalValueTextField) {
        [self setValuePickerValueFromGoalValueTextField];
    }
    else {
        [self setValuePickerValueFromRateTextField];
    }
}

- (void)setValuePickerValueFromGoalValueTextField
{
    [self setValuePickerValueWithDouble:[self valFromForm]];
}

- (void)setValuePickerValueFromRateTextField
{
    [self setValuePickerValueWithDouble:[self rateFromForm]];
}

- (void)setValuePickerValueWithDouble:(double)value
{
    if (value == 0) {
        self.pickerViewMagnitude = 0;
    }
    else {
        self.pickerViewMagnitude = MAX(0, floor(log10(ABS(value))));
    }
    [self.valuePickerView reloadAllComponents];
    int i = 0;

    while (i < self.valuePickerView.numberOfComponents) {
        int row;
//        int mag = floor(log10(ABS(value))) - i;
        int mag = self.pickerViewMagnitude - i;
        int componentVal;

        componentVal = (int)floor(fmod(ABS(value), pow(10, mag + 1))/pow(10, mag));

        if (i + 1 == self.valuePickerView.numberOfComponents) {
            componentVal = (int)round(fmod(ABS(value), pow(10, mag + 1))/pow(10, mag));
        }
        if (value == 0) {
            componentVal = 0;
        }
        if (value < 0 && i == 0) {
            componentVal = componentVal*-1;
        }
        row = i == 0 ? componentVal + 10 : componentVal;
        [self.valuePickerView selectRow:row inComponent:i animated:YES];
        i++;
    }
}

- (double)currentValue
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"goal = %@", self.goalObject];
    Datapoint *datapoint = [Datapoint MR_findFirstWithPredicate:pred sortedBy:@"timestamp" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]];
    if (datapoint) {
        return [datapoint.value doubleValue];
    }
    else if ([self.goalObject.initval doubleValue] != 0) {
        return [self.goalObject.initval doubleValue];
    }
    else if (![self.goalObject.goal_type isEqualToString:kDrinkerPrivate] && [self.presentingViewController isMemberOfClass:[NewGoalViewController class]]) {
        NewGoalViewController *ngvCon = (NewGoalViewController *)self.presentingViewController;
        RoadDialViewController *rdvCon = (RoadDialViewController *)ngvCon.topViewController;
        NSString *valueText = rdvCon.firstTextField.text;
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        return [[numberFormatter numberFromString:valueText] doubleValue];
    }
    else {
        return 0;
    }
}

- (double)rateFromForm
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    double rate = [[numberFormatter numberFromString:self.rateTextField.text] doubleValue];
    return rate;
}

- (NSDate *)dateFromForm
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    return [formatter dateFromString:self.goalDateTextField.text];
}

- (double)valFromForm
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [[numberFormatter numberFromString:self.goalValueTextField.text] doubleValue];
}

- (IBAction)editingDidBegin:(id)sender
{
    if (sender == self.goalDateTextField) {
        [sender resignFirstResponder];
        [self showDatePicker];
    }
    else {
        if (self.valuePickerView.numberOfComponents > 7) {
            self.valuePickerView.hidden = YES;
            [sender becomeFirstResponder];
        }
        else {
            [sender resignFirstResponder];
            [self showValuePicker];

            self.valuePickerTextField = sender;

            if (sender == self.rateTextField) {
                [self setValuePickerValueFromRateTextField];
            }
            else {
                [self setValuePickerValueFromGoalValueTextField];
            }
        }
    }

    int senderIndex = [self.textFieldCollection indexOfObject:sender];
    
    DCRoundSwitch *senderSwitch = [self.switchCollection objectAtIndex:senderIndex];
    
    if (!senderSwitch.on) {
        [self enableTextFieldAtIndex:senderIndex];
        int turnOffIndex = (self.switchCollection.count == senderIndex + 1) ? 0 : senderIndex + 1;
        [self disableTextFieldAtIndex:turnOffIndex];
        [(DCRoundSwitch *)[self.switchCollection objectAtIndex:turnOffIndex] setOn:NO animated:YES ignoreControlEvents:YES];
        [senderSwitch setOn:YES animated:YES ignoreControlEvents:YES];
    }
}

- (void)enableTextFieldAtIndex:(int)index
{
    UITextField *textField = [self.textFieldCollection objectAtIndex:[[NSNumber numberWithInt:index] unsignedIntegerValue]];
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blackColor];
}

- (void)disableTextFieldAtIndex:(int)index
{
    UITextField *textField = [self.textFieldCollection objectAtIndex:[[NSNumber numberWithInt:index] unsignedIntegerValue]];
    textField.backgroundColor = [UIColor lightGrayColor];
    textField.textColor = [UIColor whiteColor];
}

- (IBAction)switchValueChanged:(DCRoundSwitch *)sender
{
    int senderIndex = [self.switchCollection indexOfObject:sender];
    if (sender.on) {
        int turnOffIndex = (self.switchCollection.count == senderIndex + 1) ? 0 : senderIndex + 1;

        [self enableTextFieldAtIndex:senderIndex];
        [self disableTextFieldAtIndex:turnOffIndex];
        [(DCRoundSwitch *)[self.switchCollection objectAtIndex:turnOffIndex] setOn:NO animated:YES ignoreControlEvents:YES];
        [[self.textFieldCollection objectAtIndex:senderIndex] becomeFirstResponder];
    }
    else {
        [self disableTextFieldAtIndex:senderIndex];

        int offSwitchIndex = [self offSwitchIndexExcludingIndex:senderIndex];
        
        [self enableTextFieldAtIndex:offSwitchIndex];
        [(DCRoundSwitch *)[self.switchCollection objectAtIndex:offSwitchIndex] setOn:YES animated:YES ignoreControlEvents:YES];
        [[self.textFieldCollection objectAtIndex:senderIndex] resignFirstResponder];
        [[self.textFieldCollection objectAtIndex:offSwitchIndex] becomeFirstResponder];
    }
}

- (int)offSwitchIndexExcludingIndex:(int)excludedIndex
{
    return [[self.switchCollection indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        DCRoundSwitch *theSwitch = (DCRoundSwitch *)obj;
        
        return (idx != excludedIndex && !theSwitch.on);
    }] lastIndex];
}

- (IBAction)datePickerValueChanged
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    self.goalDateTextField.text = [formatter stringFromDate:self.datePicker.date];
    [self recalculateValues];
}

- (IBAction)cancel
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveAndDismiss:(UIBarButtonItem *)sender
{
    [self saveFormValues];
    [self dismiss];
}

- (void)saveFormValues
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    if (self.goalDateSwitch.on) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSNumber *timestamp = [NSNumber numberWithDouble:[[formatter dateFromString:self.goalDateTextField.text] timeIntervalSince1970]];
        self.goalObject.goaldate = timestamp;
    }
    else {
        self.goalObject.goaldate = nil;
    }
    
    if (self.rateSwitch.on) {
        self.goalObject.rate = [numberFormatter numberFromString:self.rateTextField.text];
    }
    else {
        self.goalObject.rate = nil;
    }
    
    if (self.goalValueSwitch.on) {
        self.goalObject.goalval = [numberFormatter numberFromString:self.goalValueTextField.text];
    }
    else {
        self.goalObject.goalval = nil;
    }
}

- (void)dismiss
{
    [self.view endEditing:YES];
    if (![self.presentingViewController isMemberOfClass:[NewGoalViewController class]]) {
        [GoalPushRequest requestForGoal:self.goalObject roadDial:YES withSuccessBlock:^{
            MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
            hud.labelText = @"Saved";
            hud.mode = MBProgressHUDModeText;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                if ([self.presentingViewController isMemberOfClass:[MainTabBarViewController class]]) {
                    MainTabBarViewController *mtvCon = (MainTabBarViewController *)self.presentingViewController;
                    UINavigationController *navCon = [mtvCon.viewControllers objectAtIndex:kGoalsTableControllerIndex];
                    GoalSummaryViewController *gsvCon = (GoalSummaryViewController *)navCon.topViewController;
                    [gsvCon pollUntilGraphIsNotUpdating];
                }
            });
        } withErrorBlock:^{
            MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
            hud.labelText = @"Could not save";
            hud.mode = MBProgressHUDModeText;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            });
        }];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Saving...";
    }
    else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
