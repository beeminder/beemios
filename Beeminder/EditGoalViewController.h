//
//  EditGoalViewController.h
//  Beeminder
//
//  Created by Andy Brett on 7/25/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditGoalViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISwitch *goalDateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *rateSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *goalValueSwitch;
@property (strong, nonatomic) IBOutlet UITextField *goalDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *rateTextField;
@property (strong, nonatomic) IBOutlet UITextField *goalValueTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) IBOutlet UIToolbar *dismissToolbar;

- (IBAction)cancel;

@end
