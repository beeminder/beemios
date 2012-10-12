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

@interface AdvancedRoalDialViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

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

@property (strong, nonatomic) IBOutlet UILabel *goalValLabel;
@property (strong, nonatomic) IBOutlet UILabel *negativeSignLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *valuePickerView;
@property (strong, nonatomic) UITextField *valuePickerTextField;

- (IBAction)cancel;
- (NSUInteger)supportedInterfaceOrientations;

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;


@end
