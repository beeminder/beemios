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
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
- (NSUInteger)supportedInterfaceOrientations;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) ACAccount *selectedTwitterAccount;
@end
