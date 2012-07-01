//
//  SignInViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController () <NSURLConnectionDelegate, UITextFieldDelegate>

- (void)formSubmitted;

@end

@implementation SignInViewController

@synthesize email = _email;
@synthesize password = _password;
@synthesize responseData = _responseData;
@synthesize responseStatus = _responseStatus;

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
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"]) {
        [self performSegueWithIdentifier:@"segueFromSigninToDashboard" sender:self];
    }
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmail:nil];
    [self setPassword:nil];
    [self setResponseData:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)formSubmitted
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/users/sign_in.json", kBaseURL];
    
    NSURL *loginUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginUrl];
    
    NSString *postString = [NSString stringWithFormat:@"user[login]=%@&user[password]=%@", self.email.text, self.password.text];

    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:loginRequest delegate:self];
    
    if (connection) {
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Authenticating..."];
        self.responseData = [NSMutableData data];
    }    
}

- (IBAction)signInButtonPressed:(UIButton *)sender
{
    [self formSubmitted];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [DejalBezelActivityView removeViewAnimated:YES];
    if (self.responseStatus == 200) {
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];

        NSDictionary *responseJSON = [responseString JSONValue];
        
        NSString *authenticationToken = [responseJSON objectForKey:@"authentication_token"];
        
        NSString *username = [responseJSON objectForKey:@"username"];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:authenticationToken forKey:@"authenticationTokenKey"];
        
        [defaults setObject:username forKey:@"username"];
        
        NSDictionary *userDict = [NSDictionary dictionaryWithObject:username forKey:@"username"];
        
        [User writeToUserWithDictionary:userDict inContext:[self managedObjectContext]];
        
        [self performSegueWithIdentifier:@"segueFromSigninToDashboard" sender:self];
    }
    else {
        self.title = @"Bad Login";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.password) {
        [theTextField resignFirstResponder];
        [self formSubmitted];
    } else if (theTextField == self.email) {
        [self.password becomeFirstResponder];
    }
    return YES;
}

@end
