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
    [super viewDidUnload];
}

- (void)editingDidBegin:(id)sender
{
    self.dismissToolbar.hidden = NO;
    if (sender == self.goalDateTextField) {
        self.datePicker.hidden = NO;
    }
}

- (IBAction)rateEditingDidBegin:(id)sender
{
    [self editingDidBegin:sender];
}

- (IBAction)dateEditingDidBegin:(id)sender
{
    [self editingDidBegin:sender];
}

- (IBAction)valueEditingDidBegin:(id)sender
{
    [self editingDidBegin:sender];
}

- (IBAction)datePickerValueChanged
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YY"];
    self.goalDateTextField.text = [formatter stringFromDate:self.datePicker.date];
}

- (void)editingDidEnd:(id)sender
{
    self.dismissToolbar.hidden = YES;
    if (sender == self.goalDateTextField) {
        self.datePicker.hidden = YES;
    }
    [sender resignFirstResponder];
}

- (IBAction)dateEditingDidEnd:(id)sender
{
    [self editingDidEnd:sender];
}

- (IBAction)rateEditingDidEnd:(id)sender
{
    [self editingDidEnd:sender];
}

- (IBAction)valueEditingDidEnd:(id)sender
{
    [self editingDidEnd:sender];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancel
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

@end
