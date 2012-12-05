//
//  ContractViewController.m
//  Beeminder
//
//  Created by Andy Brett on 12/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ContractViewController.h"

@interface ContractViewController ()

@end

@implementation ContractViewController

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
    if (self.goalObject.contract) {
        self.titleLabel.text = [NSString stringWithFormat:@"Update contract for %@", self.goalObject.title];
    }
    else {
        self.titleLabel.text = [NSString stringWithFormat:@"New contract for %@", self.goalObject.title];        
    }
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.view.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/contracts/%@/new?beemios=true&access_token=%@", kBaseURL, kPrivateAPIPrefix, self.goalObject.slug, [ABCurrentUser accessToken]]]];
    [self.webView loadRequest:request];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideAllHUDsForView:self.webView animated:YES];
    NSString *path = webView.request.URL.path;
    if ([path isEqualToString:[NSString stringWithFormat:@"/%@/goals/%@", [ABCurrentUser username], self.goalObject.slug]]) {
        
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                [self.gsvCon refreshGoalData];
            });
        }];
    }
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
