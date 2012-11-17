//
//  AuthorizeBeeminderViewController.m
//  Beeminder
//
//  Created by Andy Brett on 11/16/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "AuthorizeBeeminderViewController.h"

@interface AuthorizeBeeminderViewController ()

@end

@implementation AuthorizeBeeminderViewController

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

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/fitbit?beemios_secret=%@", kBaseURL, kBeemiosSecret]]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
    NSURL *url = webView.request.URL;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"fitbit_access_token" options:0 error:nil];
    if ([url fragment].length > 0 && [regex numberOfMatchesInString:[url fragment] options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, [url fragment].length)]) {
        NSArray *fragments = [[url fragment] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setObject:[fragments objectAtIndex:[fragments indexOfObject:@"fitbit_access_token"] + 1] forKey:kFitbitAccessTokenKey];
        [defaults setObject:[fragments objectAtIndex:[fragments indexOfObject:@"fitbit_access_token_secret"] + 1] forKey:kFitbitAccessTokenSecretKey];
        [defaults setObject:[fragments objectAtIndex:[fragments indexOfObject:@"fitbit_user_id"] + 1] forKey:kFitbitUserIdKey];
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
        [[self.rdvCon navigationController] popViewControllerAnimated:YES];
    }];

}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
