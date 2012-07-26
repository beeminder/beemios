//
//  EditGoalViewController.m
//  Beeminder
//
//  Created by Andy Brett on 7/25/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "EditGoalViewController.h"

@interface EditGoalViewController ()

@end

@implementation EditGoalViewController
@synthesize textFieldCollection;
@synthesize switchCollection;

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
    
    NSComparator compareTags = ^(id a, id b) { return [a tag] - [b tag]; };
    
    self.textFieldCollection = [self.textFieldCollection sortedArrayUsingComparator:compareTags];
    self.switchCollection = [self.switchCollection sortedArrayUsingComparator:compareTags];
    
    self.rateTextField.text = [NSString stringWithFormat:@"%@", self.goalObject.rate];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YY"];
    self.goalDateTextField.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.goalObject.goaldate doubleValue]]];
    
    if (self.goalObject.goalval) {
        self.goalValueTextField.text = [NSString stringWithFormat:@"%@", self.goalObject.goalval];
    }
    
    BOOL rate = ((id)self.goalObject.rate != [NSNull null]);
    self.rateSwitch.on = rate;
    self.rateTextField.enabled = rate;
    
    BOOL date = ((id)self.goalObject.goaldate != [NSNull null]);
    self.goalDateSwitch.on = date;
    self.goalDateTextField.enabled = date;
    
    BOOL val = [self.goalObject.goalval boolValue];
    self.goalValueSwitch.on = val;
    self.goalValueTextField.enabled = val;
    
    self.goalDateTextField.inputView = self.datePicker;
    self.rateTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.goalValueTextField.keyboardType = UIKeyboardTypeDecimalPad;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [super viewDidUnload];
}

- (IBAction)editingDidBegin:(id)sender
{
    self.dismissToolbar.hidden = NO;
    if (sender == self.goalDateTextField) {
        self.datePicker.hidden = NO;
    }
}

- (void)enableTextFieldAtIndex:(int)index
{
    UITextField *textField = [self.textFieldCollection objectAtIndex:[[NSNumber numberWithInt:index] unsignedIntegerValue]];
    textField.enabled = YES;
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [UIColor blackColor];
    [textField becomeFirstResponder];
}

- (void)disableTextFieldAtIndex:(int)index
{
    UITextField *textField = [self.textFieldCollection objectAtIndex:[[NSNumber numberWithInt:index] unsignedIntegerValue]];
    textField.enabled = NO;
    textField.backgroundColor = [UIColor lightGrayColor];
    textField.textColor = [UIColor whiteColor];
    [textField resignFirstResponder];
}

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    int senderIndex = [self.switchCollection indexOfObject:sender];
    if (sender.on) {
        int turnOffIndex = (self.switchCollection.count == senderIndex + 1) ? 0 : senderIndex + 1;

        [self enableTextFieldAtIndex:senderIndex];
        [self disableTextFieldAtIndex:turnOffIndex];
        [(UISwitch *)[self.switchCollection objectAtIndex:turnOffIndex] setOn:NO animated:YES];
    }
    else {
        [self disableTextFieldAtIndex:senderIndex];

        int offSwitchIndex = [[self.switchCollection indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {

            UISwitch *theSwitch = (UISwitch *)obj;
            
            return (idx != senderIndex && !theSwitch.on);
        }] lastIndex];
        
        [self enableTextFieldAtIndex:offSwitchIndex];
        [[self.switchCollection objectAtIndex:offSwitchIndex] setOn:YES animated:YES];
    }
}

- (IBAction)datePickerValueChanged
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YY"];
    self.goalDateTextField.text = [formatter stringFromDate:self.datePicker.date];
}

- (IBAction)cancel
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    
}

@end
