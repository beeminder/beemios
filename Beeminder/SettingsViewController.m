//
//  SettingsViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize loggedInAsLabel;
@synthesize signOutButton;

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
    self.reminderSwitchCell = [[ReminderCellUIView alloc] initWithY:53.0f];

    self.remindSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(195.0f, 11.0f, 0.0f, 0.0f)];
    [self.reminderSwitchCell addSubview:self.remindSwitch];
    
    UILabel *reminderSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0f, 9.0f, 195.0f, 30.0f)];
    reminderSwitchLabel.backgroundColor = [UIColor clearColor];
    reminderSwitchLabel.text = @"Remind me to enter data";
    reminderSwitchLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [self.reminderSwitchCell addSubview:reminderSwitchLabel];
    
    [self.view addSubview:self.reminderSwitchCell];
    
    self.reminderTimeCell = [[ReminderCellUIView alloc] initWithY:103.0f andBottomBorder:YES];
    
    self.remindAtTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 195.0f, 30.0f)];


    [self.reminderTimeCell addSubview:self.remindAtTextField];
    
    [self.view addSubview:self.reminderTimeCell];
    
    self.reminderTimePicker = [[UIDatePicker alloc] init];
    self.reminderTimePicker.datePickerMode = UIDatePickerModeTime;
    [self.reminderTimePicker addTarget:self action:@selector(timePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    self.remindAtTextField.inputView = self.reminderTimePicker;
    
    self.remindSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataKey] boolValue];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataAtKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:[BeeminderAppDelegate defaultEnterDataReminderDate] forKey:kRemindMeToEnterDataAtKey];
    }
    [self.reminderTimePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataAtKey] animated:YES];
    [self updateReminderTimeTextField];
    
    self.signOutButton = [BeeminderAppDelegate standardGrayButtonWith:self.signOutButton];
    
    self.reloadAllGoalsButton = [BeeminderAppDelegate standardGrayButtonWith:self.reloadAllGoalsButton];

    self.loggedInAsLabel.text = [NSString stringWithFormat:@"Logged in as: %@", [ABCurrentUser username]];
}

- (void)timePickerValueChanged
{
    [[NSUserDefaults standardUserDefaults] setObject:self.reminderTimePicker.date forKey:kRemindMeToEnterDataAtKey];
    [self updateReminderTimeTextField];
}

- (void)updateReminderTimeTextField
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.remindAtTextField.text = [NSString stringWithFormat:@"Every day at %@", [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataAtKey]]];
    
}

- (IBAction)remindMeToEnterDataValueChanged
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.remindSwitch.on] forKey:kRemindMeToEnterDataKey];
    if (self.remindSwitch.on) {
        [self showRemindMeToEnterDataAt];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRemindMeToEnterDataAtKey];
        [self hideRemindMeToEnterDataAt];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

//- (IBAction)remindMeToEnterDataAtTextFieldEditingDidBegin
//{
//    self.remindMeToEnterDataAtDatePicker.hidden = NO;
//    self.remindMeToEnterDataAtTextField.inputView = self.remindMeToEnterDataAtDatePicker;
//}
//
//- (IBAction)remindMeToEnterDataAtDatePickerValueChanged
//{
//    [[NSUserDefaults standardUserDefaults] setObject:[self.remindMeToEnterDataAtDatePicker date] forKey:kRemindMeToEnterDataAtKey];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//}

- (void)showRemindMeToEnterDataAt
{
    
}

- (void)hideRemindMeToEnterDataAt
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)reloadAllGoalsButtonPressed
{

    UINavigationController *navCon = [[[self tabBarController] viewControllers] objectAtIndex:0];
    GoalsTableViewController *gtvCon = [[navCon viewControllers] objectAtIndex:0];
    [ABCurrentUser resetLastUpdatedAt];
    [gtvCon fetchEverything];
    [[self tabBarController] setSelectedIndex:0];
}

- (IBAction)signOutButtonPressed {
    [ABCurrentUser logout];    
    [[[self tabBarController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setLoggedInAsLabel:nil];
    [self setSignOutButton:nil];
    [self setReloadAllGoalsButton:nil];
    [self setRemindSwitch:nil];
    [self setRemindAtTextField:nil];
    [super viewDidUnload];
}
@end
