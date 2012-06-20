//
//  GoalViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/19/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalViewController.h"
#import "SBJson.h"

@interface GoalViewController () <NSURLConnectionDelegate>

@end

@implementation GoalViewController

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
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authenticationToken = [defaults objectForKey:@"authenticationTokenKey"];
    
    NSString *username = [defaults objectForKey:@"username"];
    NSString *goalSlug = @"foo";
    
    NSURL *datapointsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/api/v1/users/%@/goals/%@/datapoints.json?auth_token=%@", username, goalSlug, authenticationToken]];
    
    NSMutableURLRequest *datapointsRequest = [NSMutableURLRequest requestWithURL:datapointsUrl];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:datapointsRequest delegate:self];
    
    if (connection) {
//        self.title = @"Fetching data...";
        self.responseData = [NSMutableData data];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - NSURLConnection delegate

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
    if (self.responseStatus == 200) {
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *responseJSON = [responseString JSONValue];
        
        NSArray *goalSlugs = [responseJSON objectForKey:@"active"];
        
//        self.goalTitles = [NSMutableArray arrayWithArray:goalSlugs];
//        
//        self.title = @"Your goals";
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//        
//        [self.tableView reloadData];
        
    }
    else {
//        self.title = @"Bad Login";
    }
}

@end
