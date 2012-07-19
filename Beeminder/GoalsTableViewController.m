//
//  GoalsTableViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalsTableViewController.h"

@interface GoalsTableViewController () <NSURLConnectionDelegate>

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
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:goalsRequest delegate:self];
        
        if (connection) {
            [DejalBezelActivityView activityViewForView:self.view];
            self.title = @"Fetching goals...";
            self.responseData = [NSMutableData data];
        }
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

#pragma mark - NSURLConnection delegate

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [DejalBezelActivityView removeView];
    if (self.responseStatus == 200) {
        NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *responseJSON = [responseString JSONValue];
        
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
    else {
        self.title = @"Bad Login";
    }
}

@end
