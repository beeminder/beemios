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
            NSLog(@"granted");
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
