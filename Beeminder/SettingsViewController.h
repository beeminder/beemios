//
//  SettingsViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoalsTableViewController.h"
#import "ReminderCellUIView.h"

@interface SettingsViewController : UIViewController<UITextFieldDelegate>

- (IBAction)signOutButtonPressed;
@property (strong, nonatomic) IBOutlet UILabel *loggedInAsLabel;
@property (strong, nonatomic) IBOutlet UIButton *signOutButton;
- (NSUInteger)supportedInterfaceOrientations;
@property (strong, nonatomic) IBOutlet UIButton *reloadAllGoalsButton;
@property (strong, nonatomic) DCRoundSwitch *remindSwitch;
@property (strong, nonatomic) DCRoundSwitch *emergencySwitch;
@property (strong, nonatomic) PRLabel *remindAtPRLabel;
@property (strong, nonatomic) UIDatePicker *reminderTimePicker;
@property (strong, nonatomic) ReminderCellUIView *reminderSwitchCell;
@property (strong, nonatomic) ReminderCellUIView *reminderTimeCell;
@property (strong, nonatomic) ReminderCellUIView *emergencyTimeCell;
@property (strong, nonatomic) ReminderCellUIView *emergencySwitchCell;
@property (strong, nonatomic) PRLabel *emergencyTimePRLabel ;
@property (strong, nonatomic) UIDatePicker *emergencyTimePicker;
@property float defaultFontSize;
@property (strong, nonatomic) NSString *defaultFontString;
@end
