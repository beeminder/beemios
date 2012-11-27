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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbSessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
    
    [GradientViews addGradient:self.view withColor:[UIColor colorWithRed:1.0 green:203.0/255.0f blue:8.0f/255.0 alpha:1.0] startAtTop:YES cornerRadius:0.0f borderColor:nil];
    self.signInButton = [BeeminderAppDelegate standardGrayButtonWith:self.signInButton];
    self.signUpButton = [BeeminderAppDelegate standardGrayButtonWith:self.signUpButton];
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [self setSignInButton:nil];
    [self setSignUpButton:nil];
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)formSubmitted
{
    NSString *paramString = [NSString stringWithFormat:@"user[login]=%@&user[password]=%@", AFURLEncodedStringFromStringWithEncoding(self.emailTextField.text, NSUTF8StringEncoding), AFURLEncodedStringFromStringWithEncoding(self.passwordTextField.text, NSUTF8StringEncoding)];
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
                
                NSString *paramString = [NSString stringWithFormat:@"oauth_user_id=%@&provider=facebook", AFURLEncodedStringFromStringWithEncoding([[NSUserDefaults standardUserDefaults] objectForKey:kFacebookUserIdKey], NSUTF8StringEncoding)];
                [self signInWithEncodedParamString:paramString];
            }
        }];
    }
}

- (void)signInWithEncodedParamString:(NSString *)paramString
{
    paramString = [paramString stringByAppendingFormat:@"&beemios_token=%@", AFURLEncodedStringFromStringWithEncoding([BeeminderAppDelegate hmacSha1SignatureForBaseString:paramString andKey:kBeemiosSigningKey], NSUTF8StringEncoding)];
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
