//
//  SignInViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Resource.h"

@interface SignInViewController : UIViewController<TwitterAuthDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet WhitePlaceholderTextField *emailTextField;
@property (strong, nonatomic) IBOutlet WhitePlaceholderTextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
- (NSUInteger)supportedInterfaceOrientations;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) IBOutlet UILabel *alternativesLabel;
@property (strong, nonatomic) ACAccount *selectedTwitterAccount;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIView *connectContainer;
@end
