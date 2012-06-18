//
//  SignInViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController () <NSURLConnectionDelegate, UITextFieldDelegate>

- (void)formSubmitted:(UIControl *)sender forEvent:(UIEvent *)event;

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

- (void)formSubmitted:(UIControl *)sender forEvent:(UIEvent *)event {
    NSURL *loginUrl = [NSURL URLWithString:@"http://localhost:3000/api/v1/users/sign_in.json"];
    
    
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginUrl];
    
    NSString *postString = [NSString stringWithFormat:@"user[login]=%@&user[password]=%@", self.email.text, self.password.text];
    NSLog(self.password.text);
    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:loginRequest delegate:self];
    
    if (connection) {
        self.title = @"Authenticating...";
        self.responseData = [NSMutableData data];
    }    
}

- (IBAction)passwordFieldSubmitted:(UITextField *)sender forEvent:(UIEvent *)event {
    [self formSubmitted:sender forEvent:event];    
}

- (IBAction)signInButtonPressed:(UIButton *)sender forEvent:(UIEvent *)event {

    [self formSubmitted:sender forEvent:event];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseStatus = [httpResponse statusCode];
    
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [self.responseData appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                 message:[error localizedDescription]
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                       otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *responseText = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];

    self.title = [NSString stringWithFormat:@"%i", self.responseStatus];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.password) {
        NSLog(@"foo");
        [theTextField resignFirstResponder];
    } else if (theTextField == self.email) {
        [self.password becomeFirstResponder];
    }
    return YES;
}

@end
