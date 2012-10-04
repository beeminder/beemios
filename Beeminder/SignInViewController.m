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
@synthesize signInButton = _signInButton;

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
    if ([ABCurrentUser accessToken]) {
        [self performSegueWithIdentifier:@"segueFromSigninToDashboard" sender:self];
    }
    [GradientViews addGradient:self.view withColor:[UIColor colorWithRed:1.0 green:203.0/255.0f blue:8.0f/255.0 alpha:1.0] startAtTop:YES cornerRadius:0.0f borderColor:nil];
    self.signInButton = [BeeminderAppDelegate standardGrayButtonWith:self.signInButton];
}

- (void)viewDidUnload
{
    [self setEmail:nil];
    [self setPassword:nil];
    [self setSignInButton:nil];
    [super viewDidUnload];
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
    
    NSString *postString = [NSString stringWithFormat:@"user[login]=%@&user[password]=%@&beemios_secret=%@", self.email.text, self.password.text, kBeemiosSecret];

    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:loginRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulLoginJSON:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self invalidLogin];
    }];
    [self.view endEditing:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Authenticating...";
    
    [operation start];
}

- (IBAction)signInButtonPressed:(UIButton *)sender
{
    [self formSubmitted];
}

- (void)successfulLoginJSON:(NSDictionary *)responseJSON
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    NSString *accessToken = [responseJSON objectForKey:@"access_token"];
    
    NSString *username = [responseJSON objectForKey:@"username"];

    [ABCurrentUser loginWithUsername:username accessToken:accessToken];
    
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", [responseJSON objectForKey:@"id"], @"serverId", nil];
    
    [User writeToUserWithDictionary:userDict];
    
    [self performSegueWithIdentifier:@"segueFromSigninToDashboard" sender:self];
    
}

- (void)invalidLogin
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
