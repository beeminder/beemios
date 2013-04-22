//
//  RoadDialViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Goal+Resource.h"
#import "GoalsTableViewController.h"
#import "AdvancedRoadDialViewController.h"
#import "ChooseGoalTypeViewController.h"
#import "AuthorizeBeeminderViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface RoadDialViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *goalTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *goalDetailsLabel;
@property (strong, nonatomic) IBOutlet UITextField *firstTextField;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet ABFlatSwitch *startFlatSwitch;
@property (strong, nonatomic) IBOutlet UIButton *roadDialButton;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) NSArray *goalSlugs;
@property (strong, nonatomic) IBOutlet UIButton *saveGoalButton;
@property (strong, nonatomic) IBOutlet UILabel *goalWarningLabel;
@property (strong, nonatomic) IBOutlet UILabel *startFlatLabel;
@property BOOL comingFromAuthorizeBeeminderView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *fitbitDatasetTitles;
@property (strong, nonatomic) NSArray *fitbitDatasetValues;
@property (strong, nonatomic) IBOutlet ABFlatSwitch *safetyBufferSwitch;
@property (strong, nonatomic) IBOutlet UILabel *safetyBufferLabel;
@property (strong, nonatomic) IBOutlet UITextField *initvalTextField;
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

- (NSUInteger)supportedInterfaceOrientations;

@end
