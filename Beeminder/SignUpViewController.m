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

@synthesize validationWarningLabel = _validationWarningLabel;
@synthesize usernameTextField = _usernameTextField;
@synthesize scrollView = _scrollView;

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
    [self registerForKeyboardNotifications];
    [GradientViews addGrayButtonGradient:self.submitButton];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    CompletionBlock completionBlock = ^() {
        [self performSegueWithIdentifier:@"segueToDashboard" sender:self];
    };
    
    [UserPushRequest requestForUser:user pushAssociations:YES additionalParams:paramsDict completionBlock:completionBlock];
}

#pragma mark Keyboard notifications

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect rect = [[self.scrollView.subviews objectAtIndex:0] frame];
    [self.scrollView setContentSize:CGSizeMake(rect.size.width, rect.size.height + kbSize.height)];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = [[self.scrollView.subviews objectAtIndex:0] frame];
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }

}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointMake(0.0, 0.0)animated:YES];
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
