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

@property (strong, nonatomic) IBOutlet ABFlatSwitch *goalDateSwitch;
@property (strong, nonatomic) IBOutlet ABFlatSwitch *rateSwitch;
@property (strong, nonatomic) IBOutlet ABFlatSwitch *goalValueSwitch;
@property (strong, nonatomic) IBOutlet UITextField *goalDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *rateTextField;
@property (strong, nonatomic) IBOutlet UITextField *goalValueTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) IBOutlet UIToolbar *dismissToolbar;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldCollection;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSMutableArray *switchCollection;
@property (strong, nonatomic) IBOutlet UILabel *delayLabel;

@property (strong, nonatomic) IBOutlet UILabel *goalValLabel;
@property (strong, nonatomic) IBOutlet UILabel *negativeSignLabel;
@property (strong, nonatomic) IBOutlet UILabel *goalDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *goalRateLabel;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)cancel;
- (NSUInteger)supportedInterfaceOrientations;

@end
