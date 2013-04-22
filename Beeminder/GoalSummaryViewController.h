//
//  GoalSummaryViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@class AdvancedRoalDialViewController;

@interface GoalSummaryViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) IBOutlet UIScrollView *graphScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *graphImageView;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIStepper *dateStepper;
@property (strong, nonatomic) IBOutlet UILabel *dateStepperLabel;
@property (strong, nonatomic) IBOutlet UIStepper *valueStepper;
@property (strong, nonatomic) IBOutlet UILabel *valueStepperLabel;

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property BOOL graphIsUpdating;
@property (strong, nonatomic) NSTimer *graphPoller;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *editGoalButton;
@property (strong, nonatomic) IBOutlet UIButton *addDataButton;
@property (strong, nonatomic) IBOutlet UILabel *lastDatapointLabel;

@property (strong, nonatomic) NSDate *datapointDate;
@property (strong, nonatomic) NSNumber *datapointDecimalValue;
@property (strong, nonatomic) NSString *datapointComment;
@property (strong, nonatomic) IBOutlet UIButton *rerailButton;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property BOOL needsFreshData;
@property (strong, nonatomic) UILabel *titleLabel;

- (void)pollUntilGraphIsNotUpdating;
- (NSUInteger)supportedInterfaceOrientations;
- (void)refreshGoalData;
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;

@end
