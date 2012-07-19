//
//  GoalSummaryViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Goal+Resource.h"
#import "GoalGraphViewController.h"
#import "DejalActivityView.h"

@interface GoalSummaryViewController : UIViewController
@property (strong, nonatomic) NSString *graphURL;
@property (strong, nonatomic) IBOutlet UIButton *graphButton;
@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;
@property (strong, nonatomic) IBOutlet UILabel *instructionLabel;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIStepper *inputStepper;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) UIImage *graphImage;

@end
