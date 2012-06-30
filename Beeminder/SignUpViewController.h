//
//  SignUpViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/26/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Create.h"
#import "User+Find.h"
#import "constants.h"
#import "Goal.h"
#import "GoalsTableViewController.h"
#import "UIViewController+NSURLConnectionDelegate.h"

@interface SignUpViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordConfirmationTextField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property NSInteger responseStatus;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *activeField;
@property (strong, nonatomic) IBOutlet UILabel *validationWarningLabel;

@end
