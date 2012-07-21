//
//  GoalsTableViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalsTableViewController.h"

@interface GoalsTableViewController ()

@end

@implementation GoalsTableViewController

@synthesize responseData = _responseData;
@synthesize responseStatus = _responseStatus;
@synthesize goals = _goals;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
    
    User *user = [User MR_findFirstByAttribute:@"username" withValue:username];
    
    NSArray *arrayOfGoalObjects = [user.goals allObjects];
    NSMutableArray *arrayOfDicts = [[NSMutableArray alloc] init];
    Goal *g;
    for (g in arrayOfGoalObjects) {
        NSDictionary *dict = [g dictionary];
        [arrayOfDicts addObject:dict];
    }
    self.goals = arrayOfDicts;
    
    if (authenticationToken) {
        
        NSURL *goalsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/users/%@/goals.json?auth_token=%@", kBaseURL, username, authenticationToken]];
        
        NSMutableURLRequest *goalsRequest = [NSMutableURLRequest requestWithURL:goalsUrl];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:goalsRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [self successfulGoalsJSON:JSON];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            [self failedFetch];
        }];
        
        [operation start];
        [DejalBezelActivityView activityViewForView:self.view];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.goals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Goal Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *goalDict = [self.goals objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [goalDict objectForKey:@"title"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToAddGoal"]) {
        // do nothing
    }
    else {
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        NSDictionary *goalDict = [self.goals objectAtIndex:path.row];
        
        NSString *slug = [goalDict objectForKey:@"slug"];
        id graphURL = [goalDict objectForKey:@"graph_url"];
        
        if (graphURL != [NSNull null]) {
            [segue.destinationViewController setGraphURL:graphURL];
        }
        [segue.destinationViewController setTitle:[goalDict objectForKey:@"title"]];
        [segue.destinationViewController setSlug:slug];
    }    
}

- (void)successfulGoalsJSON:(NSDictionary *)responseJSON
{
    [DejalBezelActivityView removeView];
    
    self.goals = [responseJSON objectForKey:@"goals"];
    
    NSDictionary *goalDict = nil;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    for (goalDict in self.goals) {
        [Goal writeToGoalWithDictionary:goalDict forUserWithUsername:username];
    }
    
    self.title = @"Your goals";
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView reloadData];
}
    
- (void)failedFetch
{
    [DejalBezelActivityView removeViewAnimated:YES];    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch goals" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
