//
//  SignUpViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/26/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SignUpViewController.h"


@interface SignUpViewController () <NSURLConnectionDelegate, UITextFieldDelegate>

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
    
    // save user
    User *user = [User findByUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]  withContext:self.managedObjectContext];
    
    user.username = self.usernameTextField.text;
    user.email = self.emailTextField.text;
    
    [self.managedObjectContext save:nil];

    Goal *goal = [[user.goals allObjects] objectAtIndex:0];
    
    // post to server
    
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/users.json", kBaseURL];
    
    NSURL *userURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *userRequest = [NSMutableURLRequest requestWithURL:userURL];
    
    NSString *userData = [NSString stringWithFormat:@"email=%@&username=%@&password=%@&goal[gtype]=hustler&goal[slug]=%@&goal[title]=%@", user.email, user.username, self.passwordTextField.text, goal.slug, goal.title];
    
    [userRequest setHTTPMethod:@"POST"];
    [userRequest setHTTPBody:[userData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:userRequest delegate:self];
    
    if (connection) {
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Saving..."];
        self.responseData = [NSMutableData data];
    }
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

#pragma mark NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.responseStatus == 200) {
        [[NSUserDefaults standardUserDefaults] setObject:self.usernameTextField.text forKey:@"username"];
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *responseJSON = [responseString JSONValue];
        
        NSString *authenticationToken = [responseJSON objectForKey:@"authentication_token"];
        
        if (!authenticationToken) {
            self.validationWarningLabel.text = @"Could not create account - username already taken";
            self.validationWarningLabel.hidden = NO;
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:authenticationToken forKey:@"authenticationTokenKey"];
        
        [self performSegueWithIdentifier:@"segueToDashboard" sender:self];
    }
    else {
        self.validationWarningLabel.text = @"Could not create account";
        self.validationWarningLabel.hidden = NO;
    }
}

@end
