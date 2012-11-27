//
//  GoalSummaryViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdvancedRoalDialViewController;

@interface GoalSummaryViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *graphButton;
@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIStepper *dateStepper;
@property (strong, nonatomic) IBOutlet UIStepper *valueStepper;

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property BOOL graphIsUpdating;
@property (strong, nonatomic) NSTimer *graphPoller;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *editGoalButton;
@property (strong, nonatomic) IBOutlet UIButton *addDataButton;
@property (strong, nonatomic) IBOutlet UILabel *lastDatapointLabel;

@property (strong, nonatomic) NSDate *datapointDate;
@property (strong, nonatomic) NSNumber *datapointDecimalValue;
@property (strong, nonatomic) NSString *datapointComment;

- (void)pollUntilGraphIsNotUpdating;
- (NSUInteger)supportedInterfaceOrientations;

@end
