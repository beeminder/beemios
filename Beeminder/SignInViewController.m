//
//  SignInViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController () <UITextFieldDelegate>

- (void)formSubmitted;

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.connectContainer.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionStateChanged:) name:FBSessionStateChangedNotification object:nil];

    self.view.backgroundColor = [BeeminderAppDelegate cloudsColor];
    self.signInButton = [BeeminderAppDelegate standardGrayButtonWith:self.signInButton];
    self.signUpButton = [BeeminderAppDelegate standardGrayButtonWith:self.signUpButton];
    self.alternativesLabel.font = [UIFont fontWithName:@"Lato" size:15.0f];
    self.emailTextField.font = [UIFont fontWithName:@"Lato" size:15.0f];
    self.passwordTextField.font = [UIFont fontWithName:@"Lato" size:15.0f];
    self.emailTextField.textColor = [UIColor blackColor];

    self.emailTextField.backgroundColor = [BeeminderAppDelegate silverColor];
    self.passwordTextField.backgroundColor = [BeeminderAppDelegate silverColor];
    self.emailTextField.layer.borderColor = [UIColor clearColor].CGColor;
    self.passwordTextField.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setSignInButton:nil];
    [self setSignUpButton:nil];
    [self setAlternativesLabel:nil];
    [self setTwitterButton:nil];
    [self setFacebookButton:nil];
    [self setConnectContainer:nil];
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)formSubmitted
{
    NSString *paramString = [NSString stringWithFormat:@"beemios_secret=%@&user[login]=%@&user[password]=%@", kBeemiosSecret, AFURLEncodedStringFromStringWithEncoding(self.emailTextField.text, NSUTF8StringEncoding), AFURLEncodedStringFromStringWithEncoding(self.passwordTextField.text, NSUTF8StringEncoding)];
    [self signInWithEncodedParamString:paramString];
}

- (IBAction)signInButtonPressed:(UIButton *)sender
{
    [self formSubmitted];
}

- (IBAction)signUpButtonPressed
{
    [self dismiss];
}

- (IBAction)signInWithFacebookButtonPressed
{
    [BeeminderAppDelegate removeStoredOAuthDefaults];
    BeeminderAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // The user has initiated a login, so call the openSession method
    // and show the login UX if necessary.
    [BeeminderAppDelegate removeStoredOAuthDefaults];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (IBAction)signInWithTwitterButtonPressed
{
    [BeeminderAppDelegate removeStoredOAuthDefaults];
    [BeeminderAppDelegate requestAccessToTwitterFromView:self.view withDelegate:self];
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
            if (!error) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[result username] forKey:kFacebookUsernameKey];
                [defaults setObject:[result id] forKey:kFacebookUserIdKey];
                
                NSString *paramString = [NSString stringWithFormat:@"email=%@&facebook_access_token=%@&facebook_username=%@&oauth_user_id=%@&provider=facebook", AFURLEncodedStringFromStringWithEncoding([result email], NSUTF8StringEncoding), FBSession.activeSession.accessToken, [result username], AFURLEncodedStringFromStringWithEncoding([[NSUserDefaults standardUserDefaults] objectForKey:kFacebookUserIdKey], NSUTF8StringEncoding)];
                [self signInWithEncodedParamString:paramString];
            }
        }];
    }
}

- (void)signInWithEncodedParamString:(NSString *)paramString
{
    paramString = [BeeminderAppDelegate addDeviceTokenToParamString:paramString];
    NSString *urlString = [NSString stringWithFormat:@"%@/api/private/sign_in.json", kBaseURL];
    
    NSURL *loginUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginUrl];
    
    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:loginRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulLoginJSON:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if ([JSON objectForKey:@"errors"]) {
            [self invalidLoginMessage:[[JSON objectForKey:@"errors"] objectForKey:@"message"]];
        }
        else {
            [self invalidLoginMessage:@"Could not reach Beeminder"];
        }

    }];
    [self.view endEditing:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Authenticating...";
    hud.labelFont = [UIFont fontWithName:@"Lato" size:14.0f];
    
    [operation start];
}

#pragma mark TwitterAuthDelegate methods

- (void)didSuccessfullyAuthWithTwitter
{
    NSString *paramString = [NSString stringWithFormat:@"oauth_user_id=%@&provider=twitter", AFURLEncodedStringFromStringWithEncoding([[NSUserDefaults standardUserDefaults] objectForKey:kTwitterUserIdKey], NSUTF8StringEncoding)];
    [self signInWithEncodedParamString:paramString];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex + 1 >= actionSheet.numberOfButtons) {
        return;
    }
    self.selectedTwitterAccount = [self.twitterAccounts objectAtIndex:buttonIndex];
    [BeeminderAppDelegate getReverseAuthTokensForTwitterAccount:self.selectedTwitterAccount fromView:self.view withDelegate:self];
}

- (void)successfulLoginJSON:(NSDictionary *)responseJSON
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSString *accessToken = [responseJSON objectForKey:@"access_token"];
    
    NSString *username = [responseJSON objectForKey:@"username"];

    [ABCurrentUser loginWithUsername:username accessToken:accessToken];
    
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:responseJSON];
    [userDict setObject:[responseJSON objectForKey:@"id"] forKey:@"serverId"];
    [userDict setObject:[responseJSON objectForKey:@"has_authorized_fitbit"]  forKey:@"hasAuthorizedFitbit"];
    [userDict removeObjectForKey:@"id"];
    [userDict removeObjectForKey:@"goals"];
    [userDict removeObjectForKey:@"has_authorized_fitbit"];
    
    [User writeToUserWithDictionary:userDict];
    [self dismiss];
}

- (void)dismiss
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];    
}

- (void)invalidLoginMessage:(NSString *)message
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not log in" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.passwordTextField) {
        [theTextField resignFirstResponder];
        [self formSubmitted];
    } else if (theTextField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

@end
