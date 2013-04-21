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

    self.defaultFontString = @"Lato";
    self.defaultFontSize = 15.0f;
    
    self.view.backgroundColor = [BeeminderAppDelegate cloudsColor];
    
    // Begin ReminderSwitchCell
    self.reminderSwitchCell = [[ReminderCellUIView alloc] initWithYPosition:52.0f showBottomBorder:NO];
    self.remindSwitch = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(195.0f, 11.0f, 80.0f, 30.0f)];
    self.remindSwitch.onTintColor = [BeeminderAppDelegate nephritisColor];
    self.remindSwitch.labelFont = [UIFont fontWithName:@"Lato-Bold" size:16.0f];
    self.remindSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataKey] boolValue];    
    [self.remindSwitch addTarget:self action:@selector(remindSwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.reminderSwitchCell addSubview:self.remindSwitch];
    
    UILabel *reminderSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0f, 9.0f, 195.0f, 30.0f)];
    reminderSwitchLabel.backgroundColor = [UIColor clearColor];
    reminderSwitchLabel.text = @"Remind me to enter data";
    reminderSwitchLabel.font = [UIFont fontWithName:self.defaultFontString size:self.defaultFontSize];
    [self.reminderSwitchCell addSubview:reminderSwitchLabel];
    
    self.loggedInAsLabel.font = [UIFont fontWithName:self.defaultFontString size:self.defaultFontSize];
    
    [self.view addSubview:self.reminderSwitchCell];
    
    // Begin ReminderTimeCell
    self.reminderTimePicker = [[UIDatePicker alloc] init];
    self.reminderTimePicker.datePickerMode = UIDatePickerModeTime;
    self.reminderTimePicker.minuteInterval = 5.0f;
    [self.reminderTimePicker addTarget:self action:@selector(timePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    self.reminderTimeCell = [[ReminderCellUIView alloc] initWithYPosition:103.0f showBottomBorder:YES];
    self.remindAtPRLabel = [[PRLabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 195.0f, 30.0f)];
    self.remindAtPRLabel.inputView = self.reminderTimePicker;
    self.remindAtPRLabel.font = [UIFont fontWithName:self.defaultFontString size:self.defaultFontSize];
    self.remindAtPRLabel.backgroundColor = [UIColor clearColor];
    [self.reminderTimeCell addSubview:self.remindAtPRLabel];
    
    [self.view addSubview:self.reminderTimeCell];
    
    // Begin Emergency Cell
    self.emergencySwitchCell = [[ReminderCellUIView alloc] initWithYPosition:154.0 showBottomBorder:YES];
    self.emergencySwitch = [[DCRoundSwitch alloc] init];
    self.emergencySwitch.frame = CGRectMake(195.0f, 11.0f, 80.0f, 30.0f);
    self.emergencySwitch.labelFont = [UIFont fontWithName:@"Lato-Bold" size:16.0f];
    self.emergencySwitch.onTintColor = [BeeminderAppDelegate nephritisColor];
    self.emergencySwitch.on = [ABCurrentUser emergencyDayNotifications];
    [self.emergencySwitch addTarget:self action:@selector(emergencySwitchValueChanged) forControlEvents:UIControlEventValueChanged];
    UILabel *emergencySwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(9.0f, 9.0f, 195.0f, 30.0f)];
    emergencySwitchLabel.backgroundColor = [UIColor clearColor];
    emergencySwitchLabel.text = @"Emergency Day notifications";
    emergencySwitchLabel.font = [UIFont fontWithName:self.defaultFontString size:14.0f];
    [self.emergencySwitchCell addSubview:emergencySwitchLabel];
    [self.emergencySwitchCell addSubview:self.emergencySwitch];
    
    [self.view addSubview:self.emergencySwitchCell];
    
    // Begin EmergencyTimeCell
    self.emergencyTimePicker = [[UIDatePicker alloc] init];
    self.emergencyTimePicker.datePickerMode = UIDatePickerModeTime;
    self.emergencyTimePicker.minuteInterval = 5.0f;
    [self.emergencyTimePicker addTarget:self action:@selector(emergencyTimePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    self.emergencyTimeCell = [[ReminderCellUIView alloc] initWithYPosition:205.0 showBottomBorder:YES];
    self.emergencyTimePRLabel = [[PRLabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 235.0f, 30.0f)];
    self.emergencyTimePRLabel.inputView = self.emergencyTimePicker;
    self.emergencyTimePRLabel.font = [UIFont fontWithName:self.defaultFontString size:self.defaultFontSize];
    self.emergencyTimePRLabel.backgroundColor = [UIColor clearColor];
    [self.emergencyTimeCell addSubview:self.emergencyTimePRLabel];
    
    [self.view addSubview:self.emergencyTimeCell];
    
    if (!self.remindSwitch.on) {
        [self hideRemindMeToEnterDataAt];
    }
    
    if (!self.emergencySwitch.on) {
        [self hideEmergencyTime];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataAtKey]) {
        [[NSUserDefaults standardUserDefaults] setObject:[BeeminderAppDelegate defaultEnterDataReminderDate] forKey:kRemindMeToEnterDataAtKey];
    }
    
    [self.reminderTimePicker setDate:[[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataAtKey] animated:YES];
    [self updateReminderTimePRLabel];
    
    [self.emergencyTimePicker setDate:[ABCurrentUser emergencyNotificationDate] animated:YES];
    [self updateEmergencyTimePRLabel];
    
    self.signOutButton = [BeeminderAppDelegate standardGrayButtonWith:self.signOutButton];
    
    self.reloadAllGoalsButton = [BeeminderAppDelegate standardGrayButtonWith:self.reloadAllGoalsButton];

    self.loggedInAsLabel.text = [NSString stringWithFormat:@"Logged in as: %@", [ABCurrentUser username]];
}

- (void)emergencySwitchValueChanged
{
    [ABCurrentUser setEmergencyDayNotifications:self.emergencySwitch.on];
    if (self.emergencySwitch.on) {
        [BeeminderAppDelegate requestPushNotificationAccess];
        [ABCurrentUser setEmergencyNotificationDate:self.emergencyTimePicker.date];
        [self syncEmergencyTimeToServer];
        [self showEmergencyTime];
    }
    else {
        [BeeminderAppDelegate removeDeviceTokenFromServer];
        [self hideEmergencyTime];
    }
}

- (void)timePickerValueChanged
{
    [[NSUserDefaults standardUserDefaults] setObject:self.reminderTimePicker.date forKey:kRemindMeToEnterDataAtKey];
    [self updateReminderTimePRLabel];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [BeeminderAppDelegate scheduleEnterDataReminders];
}

- (void)emergencyTimePickerValueChanged
{
    [ABCurrentUser setEmergencyNotificationDate:self.emergencyTimePicker.date];
    [self updateEmergencyTimePRLabel];
    [self syncEmergencyTimeToServer];
}

- (void)syncEmergencyTimeToServer
{
    if (![ABCurrentUser emergencyDayNotifications]) {
        return;
    }

    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned timeUnitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:timeUnitFlags fromDate:[ABCurrentUser emergencyNotificationDate]];
    
    NSInteger panic = 86400 - (60*(60*[components hour] + [components minute]));
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/me.json?access_token=%@&panic=%d", kBaseURL, kAPIPrefix,[ABCurrentUser accessToken], panic]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"PUT"];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //foo
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //bar
    }];
    
    [operation start];
}

- (void)updateReminderTimePRLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.remindAtPRLabel.text = [NSString stringWithFormat:@"Every day at %@", [formatter stringFromDate:[[NSUserDefaults standardUserDefaults] objectForKey:kRemindMeToEnterDataAtKey]]];
}

- (void)updateEmergencyTimePRLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.emergencyTimePRLabel.text = [NSString stringWithFormat:@"On emergency days at %@", [formatter stringFromDate:[ABCurrentUser emergencyNotificationDate]]];
}

- (void)remindSwitchValueChanged
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.remindSwitch.on] forKey:kRemindMeToEnterDataKey];
    [self.remindAtPRLabel resignFirstResponder];
    if (self.remindSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setObject:self.reminderTimePicker.date forKey:kRemindMeToEnterDataAtKey];
        [self showRemindMeToEnterDataAt];
        [BeeminderAppDelegate scheduleEnterDataReminders];        
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRemindMeToEnterDataAtKey];
        [self hideRemindMeToEnterDataAt];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)showRemindMeToEnterDataAt
{
    self.reminderTimeCell.hidden = NO;
    self.reminderSwitchCell.bottomBorder.hidden = YES;
}

- (void)hideRemindMeToEnterDataAt
{
    self.reminderTimeCell.hidden = YES;    
    self.reminderSwitchCell.bottomBorder.hidden = NO;
}

- (void)showEmergencyTime
{
    self.emergencyTimeCell.hidden = NO;
    self.emergencySwitchCell.bottomBorder.hidden = YES;
}

- (void)hideEmergencyTime
{
    self.emergencyTimeCell.hidden = YES;
    self.emergencySwitchCell.bottomBorder.hidden = NO;
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
    [self setRemindAtPRLabel:nil];
    [super viewDidUnload];
}
@end
