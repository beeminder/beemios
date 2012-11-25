//
//  SignUpViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/26/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Resource.h"
#import "Goal.h"
#import "GoalsTableViewController.h"
#import "UserPushRequest.h"

@interface SignUpViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordConfirmationTextField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *activeField;
@property (strong, nonatomic) IBOutlet UILabel *validationWarningLabel;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) ACAccount *selectedTwitterAccount;
@property (strong, nonatomic) IBOutlet UILabel *signUpWithServiceLabel;
@property (strong, nonatomic) IBOutlet UIButton *signUpWithTwitterButton;
@property (strong, nonatomic) IBOutlet UILabel *promptLabel;

- (IBAction)usernameValueChanged;
- (NSUInteger)supportedInterfaceOrientations;
@end
