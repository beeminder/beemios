//
//  SignUpViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/26/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController () <UITextFieldDelegate>

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)requestAccessToTwitter
{
    [BeeminderAppDelegate requestAccessToTwitterFromView:self.view withDelegate:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= [self.twitterAccounts count]) {
        return;
    }
    self.selectedTwitterAccount = [self.twitterAccounts objectAtIndex:buttonIndex];
    [BeeminderAppDelegate getReverseAuthTokensForTwitterAccount:self.selectedTwitterAccount fromView:self.view withDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
    self.submitButton = [BeeminderAppDelegate standardGrayButtonWith:self.submitButton];
}

- (void)fbSessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen) {
        [[NSUserDefaults standardUserDefaults] setObject:FBSession.activeSession.accessToken forKey:kFacebookOAuthTokenKey];

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        FBRequest *request = [FBRequest requestForMe];
        
        [request setSession:FBSession.activeSession];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            self.emailTextField.text = [result email];
            [self updateFormAfterAuthWithUsername:[result username] prompt:@"Success! Choose a Beeminder username or confirm to use the same username as Facebook."];
            [defaults setObject:[result username] forKey:kFacebookUsernameKey];
            [defaults setObject:[result id] forKey:kFacebookUserIdKey];
        }];
    }
}

- (void)updateFormAfterAuthWithUsername:(NSString *)username prompt:(NSString *)prompt
{
    self.emailTextField.hidden = YES;
    self.usernameTextField.text = username;
    self.passwordConfirmationTextField.hidden = YES;
    self.passwordTextField.hidden = YES;
    self.signUpWithServiceLabel.hidden = YES;
    self.signUpWithTwitterButton.hidden = YES;
    self.signUpWithFacebookButton.hidden = YES;
    self.promptLabel.text = prompt;
    double offset = 30.0f;
    CGRect frame = self.promptLabel.frame;
    self.promptLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + offset);
    CGRect valFrame = self.validationWarningLabel.frame;
    self.validationWarningLabel.frame = CGRectMake(valFrame.origin.x, valFrame.origin.y + offset, valFrame.size.width, valFrame.size.height);
    CGRect uFrame = self.usernameTextField.frame;
    self.usernameTextField.frame = CGRectMake(uFrame.origin.x, uFrame.origin.y + offset, uFrame.size.width, uFrame.size.height);
    [self usernameValueChanged];
}

- (void)didSuccessfullyAuthWithFacebook
{
    
}

- (void)didSuccessfullyAuthWithTwitter
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self updateFormAfterAuthWithUsername:self.selectedTwitterAccount.username prompt:@"Success! Choose a Beeminder username or confirm to use the same username as Twitter."];
}

- (IBAction)signUpWithTwitterButtonPressed
{
    [BeeminderAppDelegate removeStoredOAuthDefaults];
    [self requestAccessToTwitter];
}

- (IBAction)signUpWithFacebookButtonPressed
{
    BeeminderAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [BeeminderAppDelegate removeStoredOAuthDefaults];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (void)viewDidUnload
{
    [self setUsernameTextField:nil];
    [self setScrollView:nil];
    [self setValidationWarningLabel:nil];
    [self setSignUpWithServiceLabel:nil];
    [self setSignUpWithTwitterButton:nil];
    [self setPromptLabel:nil];
    [self setSignUpWithFacebookButton:nil];
    [super viewDidUnload];
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setPasswordConfirmationTextField:nil];
    [self setSubmitButton:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[self.navigationController navigationBar] setHidden:YES];
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (IBAction)submitButtonPressed
{
    self.validationWarningLabel.hidden = YES;
    if (![self.passwordTextField.text isEqualToString:self.passwordConfirmationTextField.text]) {
        self.validationWarningLabel.text = @"Password and confirmation do not match";
        self.validationWarningLabel.hidden = NO;
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kTwitterOAuthTokenKey] &&
        ![self validateEmailWithString:self.emailTextField.text]) {
        self.validationWarningLabel.text = @"Invalid email address";
        self.validationWarningLabel.hidden = NO;
        return;
    }

    User *user = [ABCurrentUser user];
    
    user.username = self.usernameTextField.text;
    
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:self.usernameTextField.text, @"username", self.emailTextField.text, @"email", nil];
    
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:self.passwordTextField.text, @"password", nil];
    
    user = [User writeToUserWithDictionary:userDict];
    user.goals = [NSSet setWithObject:[BeeminderAppDelegate sharedSessionGoal]];
    
    CompletionBlock successBlock = ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];        
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    CompletionBlock errorBlock = ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.validationWarningLabel.text = @"Username already taken";
        self.validationWarningLabel.hidden = NO;
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view endEditing:YES];
    [UserPushRequest requestForUser:user pushAssociations:YES additionalParams:paramsDict successBlock:successBlock errorBlock:errorBlock];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;

    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)usernameCheckSuccessJSON:(id)responseJSON
{
    if ([[responseJSON objectForKey:@"exists"] isEqualToString:@"true"]) {
        self.validationWarningLabel.text = @"Username already taken";
        self.validationWarningLabel.hidden = NO;
        self.submitButton.enabled = NO;
    }
    
    else {
        self.validationWarningLabel.hidden = YES;
        self.submitButton.enabled = YES;
    }
}

- (void)usernameCheckFailed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not reach server" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)usernameValueChanged 
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/private/usernames.json?search=%@", kBaseURL, self.usernameTextField.text];
    
    NSURL *usernameUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *usernameRequest = [NSMutableURLRequest requestWithURL:usernameUrl];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:usernameRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self usernameCheckSuccessJSON:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self usernameCheckFailed];
    }];
    
    [operation start];
}

@end
