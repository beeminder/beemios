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

@synthesize email = _email;
@synthesize password = _password;

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
    if ([ABCurrentUser authenticationToken]) {
        [self performSegueWithIdentifier:@"segueFromSigninToDashboard" sender:self];
    }
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setEmail:nil];
    [self setPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)formSubmitted
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/private/sign_in.json", kBaseURL];
    
    NSURL *loginUrl = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *loginRequest = [NSMutableURLRequest requestWithURL:loginUrl];
    
    NSString *postString = [NSString stringWithFormat:@"user[login]=%@&user[password]=%@", self.email.text, self.password.text];

    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:loginRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulLoginJSON:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self invalidLogin];
    }];
    
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Authenticating..."];
    
    [operation start];
}

- (IBAction)signInButtonPressed:(UIButton *)sender
{
    [self formSubmitted];
}

- (void)successfulLoginJSON:(NSDictionary *)responseJSON
{
    [DejalBezelActivityView removeViewAnimated:YES];
    
    NSString *authenticationToken = [responseJSON objectForKey:@"authentication_token"];
    
    NSString *username = [responseJSON objectForKey:@"username"];

    [ABCurrentUser loginWithUsername:username authenticationToken:authenticationToken];
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", [responseJSON objectForKey:@"id"], @"serverId", nil];
    
    [User writeToUserWithDictionary:userDict];
    
    [self performSegueWithIdentifier:@"segueFromSigninToDashboard" sender:self];
    
}

- (void)invalidLogin
{
    [DejalBezelActivityView removeViewAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bad Login" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
