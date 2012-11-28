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
@property (strong, nonatomic) UISwitch *remindSwitch;
@property (strong, nonatomic) IBOutlet UITextField *remindAtTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *reminderTimePicker;
@property (strong, nonatomic) ReminderCellUIView *reminderSwitchCell;
@property (strong, nonatomic) ReminderCellUIView *reminderTimeCell;
@end
