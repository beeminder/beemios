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
    self.alternativesLabel.font = [UIFont fontWithName:@"Lato" size:15.0f];
    self.emailTextField.font = [UIFont fontWithName:@"Lato" size:22.0f];
    self.passwordTextField.font = [UIFont fontWithName:@"Lato" size:22.0f];
    self.emailTextField.textColor = [UIColor blackColor];

    self.emailTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
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

- (void)formSubmitted
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:kBeemiosSecret, @"beemios_secret", [BeeminderAppDelegate encodedString:self.emailTextField.text], @"user[login]", [BeeminderAppDelegate encodedString:self.passwordTextField.text], @"user[password]", nil];
    [self signInWithEncodedParams:params];
}

- (IBAction)signInButtonPressed:(UIButton *)sender
{
    [self formSubmitted];
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
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Signing into Twitter...";
    hud.labelFont = [UIFont fontWithName:@"Lato" size:14.0f];
    [BeeminderAppDelegate removeStoredOAuthDefaults];
    [BeeminderAppDelegate requestAccessToTwitterFromView:self.view withDelegate:self];
}

- (void)fbSessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen) {
        [[NSUserDefaults standardUserDefaults] setObject:FBSession.activeSession.accessTokenData.accessToken forKey:kFacebookOAuthTokenKey];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        FBRequest *request = [FBRequest requestForMe];
        
        [request setSession:FBSession.activeSession];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (!error) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[result username] forKey:kFacebookUsernameKey];
                [defaults setObject:[result id] forKey:kFacebookUserIdKey];
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[BeeminderAppDelegate encodedString:[result email]], @"email", FBSession.activeSession.accessTokenData.accessToken, @"facebook_access_token", [result username], @"facebook_username", [BeeminderAppDelegate encodedString:[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookUserIdKey]], @"oauth_user_id", @"facebook", @"provider", nil];
                [self signInWithEncodedParams:[BeeminderAppDelegate addDeviceTokenToParamsDict:params]];
            }
        }];
    }
}

- (void)signInWithEncodedParams:(NSDictionary *)params
{
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager POST:[NSString stringWithFormat:@"/api/private/sign_in.json"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self successfulLoginJSON:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];

        if ([operation.responseObject isKindOfClass:[NSDictionary class]]) {
            hud.labelText = [NSString stringWithFormat:@"Authentication failed: %@", [[operation.responseObject objectForKey:@"errors"] objectForKey:@"message"]];
        }
        else {
            hud.labelText = [NSString stringWithFormat:@"Authentication failed!"];
        }
        hud.mode = MBProgressHUDModeText;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    }];
    
    [self.view endEditing:YES];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Authenticating...";
    hud.labelFont = [UIFont fontWithName:@"Lato" size:14.0f];
}

#pragma mark TwitterAuthDelegate methods

- (void)didSuccessfullyAuthWithTwitter
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[BeeminderAppDelegate encodedString:[[NSUserDefaults standardUserDefaults] objectForKey:kTwitterUserIdKey]], @"oauth_user_id", @"twitter", @"provider", nil];
    [self signInWithEncodedParams:[BeeminderAppDelegate addDeviceTokenToParamsDict:params]];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signedIn" object:self];
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
