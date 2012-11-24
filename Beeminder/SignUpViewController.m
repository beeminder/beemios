//
//  SignUpViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/26/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SignUpViewController.h"
#import "NSString+Base64.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.submitButton = [BeeminderAppDelegate standardGrayButtonWith:self.submitButton];
    
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];

			if ([accountsArray count] > 0) {
                
                if (YES) {//[accountsArray count] == 1) {
                    ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                    
                    NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
                    
                    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
                    NSUInteger length = 32;
                    NSMutableString *nonce = [NSMutableString stringWithCapacity: length];
                    
                    for (int i=0; i<length; i++) {
                        [nonce appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
                    }                    
                    
                    NSDictionary *baseParams = [NSDictionary dictionaryWithObjectsAndKeys:
                        kTwitterConsumerKey, @"oauth_consumer_key",
                        nonce, @"oauth_nonce",
                        @"HMAC-SHA1", @"oauth_signature_method",
                        timestamp, @"oauth_timestamp",
                        @"1.0", @"oauth_version",
                        @"reverse_auth", @"x_auth_mode", nil];
                    
                    NSString *paramString = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=%@&x_auth_mode=reverse_auth", [baseParams objectForKey:@"oauth_consumer_key"], [baseParams objectForKey:@"oauth_nonce"], [baseParams objectForKey:@"oauth_signature_method"], [baseParams objectForKey:@"oauth_timestamp"], [baseParams objectForKey:@"oauth_version"]];
                    
                    NSString *signatureBaseString = [NSString stringWithFormat:@"POST&https%%3A%%2F%%2Fapi.twitter.com%%2Foauth%%2Frequest_token&%@", AFURLEncodedStringFromStringWithEncoding(paramString, NSUTF8StringEncoding)];
                    NSString *signingKey = [NSString stringWithFormat:@"%@&", kTwitterConsumerSecret];

                    const char *cKey  = [signingKey cStringUsingEncoding:NSASCIIStringEncoding];
                    const char *cData = [signatureBaseString cStringUsingEncoding:NSASCIIStringEncoding];
                    
                    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
                    
                    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
                    
                    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                                          length:sizeof(cHMAC)];
                    
                    NSString *signature = [NSString base64StringFromData:HMAC length:HMAC.length];
                    
                    NSString *headerString = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", oauth_version=\"%@\"", [baseParams objectForKey:@"oauth_consumer_key"], [baseParams objectForKey:@"oauth_nonce"], AFURLEncodedStringFromStringWithEncoding(signature, NSUTF8StringEncoding), [baseParams objectForKey:@"oauth_signature_method"], [baseParams objectForKey:@"oauth_timestamp"], [baseParams objectForKey:@"oauth_version"], nil];
                
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"]];
                    [request setHTTPBody:[@"x_auth_mode=reverse_auth" dataUsingEncoding:NSUTF8StringEncoding]];
                    [request setHTTPMethod:@"POST"];
                    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:headerString, @"Authorization", nil]];
                
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSString *responseString = [operation responseString];
                        NSDictionary *step2Params = [[NSMutableDictionary alloc] init];
                        [step2Params setValue:kTwitterConsumerKey forKey:@"x_reverse_auth_target"];
                        [step2Params setValue:responseString forKey:@"x_reverse_auth_parameters"];
                        
                        NSURL *url2 = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
                        TWRequest *stepTwoRequest =
                        [[TWRequest alloc] initWithURL:url2 parameters:step2Params requestMethod:TWRequestMethodPOST];
                        [stepTwoRequest setAccount:twitterAccount];
                        [stepTwoRequest performRequestWithHandler:
                         ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                             NSString *responseStr =
                             [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];
                             NSLog(@"The user's info for your server:\n%@", responseStr);
                         }];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        //foo
                        NSLog(@"%@", error);
                    }];
                    [operation start];
                }
                else {
                    // ask the user which one they want to use
                }

			}
        }
        else {
            NSLog(@"not");
        }
    }];
}

- (void)viewDidUnload
{
    [self setUsernameTextField:nil];
    [self setScrollView:nil];
    [self setValidationWarningLabel:nil];
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
    
    if (![self validateEmailWithString:self.emailTextField.text]) {
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
    }
    
    else {
        self.validationWarningLabel.hidden = YES;
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
