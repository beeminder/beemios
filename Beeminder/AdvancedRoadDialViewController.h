//
//  AdvancedRoalDialViewController.h
//  Beeminder
//
//  Created by Andy Brett on 7/25/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoalSummaryViewController.h"

@class RoadDialViewController;

@interface AdvancedRoalDialViewController : UIViewController

@property (strong, nonatomic) IBOutlet DCRoundSwitch *goalDateSwitch;
@property (strong, nonatomic) IBOutlet DCRoundSwitch *rateSwitch;
@property (strong, nonatomic) IBOutlet DCRoundSwitch *goalValueSwitch;
@property (strong, nonatomic) IBOutlet UITextField *goalDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *rateTextField;
@property (strong, nonatomic) IBOutlet UITextField *goalValueTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) IBOutlet UIToolbar *dismissToolbar;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldCollection;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSMutableArray *switchCollection;
@property (strong, nonatomic) IBOutlet UILabel *delayLabel;
@property (strong, nonatomic) RoadDialViewController *rdvCon;
@property (strong, nonatomic) GoalSummaryViewController *gsvCon;

- (IBAction)cancel;

@end
