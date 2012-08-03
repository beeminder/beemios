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

    NSString *username = [defaults objectForKey:@"username"];
    
    User *user = [User MR_findFirstByAttribute:@"username" withValue:username];
    
    NSArray *arrayOfGoalObjects = [user.goals allObjects];
    self.goalObjects = [NSMutableArray arrayWithArray:arrayOfGoalObjects];

    [self checkTimestamp];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *authenticationToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];
    
    if (!authenticationToken) [self failedFetch]; return;
    
    [self checkTimestamp];
}

- (void)fetchEverything
{
    NSString *authenticationToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];
    
    if (!authenticationToken) {
        [self failedFetch];
        return;
    }
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    int lastUpdatedAt = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUpdatedAt"];
    
    NSURL *fetchUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@.json?associations=true&diff_since=%d&auth_token=%@", kBaseURL, kAPIPrefix, username, lastUpdatedAt, authenticationToken]];
    
    NSURLRequest *fetchRequest = [NSURLRequest requestWithURL:fetchUrl];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(int)[[NSDate date] timeIntervalSince1970] forKey:@"lastUpdatedAt"];
    
    AFJSONRequestOperation *fetchOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:fetchRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulFetchEverythingJSON:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self failedFetch];
    }];
    
    [fetchOperation start];
    [DejalBezelActivityView activityViewForView:self.view];
  
}

- (void)checkTimestamp
{
    NSString *authenticationToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];
    
    if (!authenticationToken) {
        [self failedFetch];
        return;
    }
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    NSURL *checkUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@.json?auth_token=%@", kBaseURL, kAPIPrefix, username, authenticationToken]];
    
    NSURLRequest *checkRequest = [NSURLRequest requestWithURL:checkUrl];
    
    AFJSONRequestOperation *checkOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:checkRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        int lastUpdatedAt = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUpdatedAt"];        
        if ([[JSON objectForKey:@"updated_at"] intValue] > lastUpdatedAt) {
            [self fetchEverything];
        }
        else {
            [DejalBezelActivityView removeView];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self failedFetch];
    }];
    
    [checkOperation start];
    [DejalBezelActivityView activityViewForView:self.view];
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
    return [self.goalObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Goal Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    Goal *goalObject = [self.goalObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = goalObject.title;
    if (self.goalObjects.count > 0) {
        Goal *goal = [self.goalObjects objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d days", goal.countdownDays];
        cell.detailTextLabel.textColor = goal.countdownColor;
    }

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
        Goal *goalObject = [self.goalObjects objectAtIndex:path.row];
        [segue.destinationViewController setTitle:goalObject.title];
        [segue.destinationViewController setGoalObject:goalObject];
    }
}

- (void)successfulFetchEverythingJSON:(NSDictionary *)responseJSON
{
    [DejalBezelActivityView removeView];
    
    NSArray *goals = [responseJSON objectForKey:@"goals"];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    [self.goalObjects removeAllObjects];
    
    for (NSDictionary *goalDict in goals) {
        NSMutableDictionary *modGoalDict = [NSMutableDictionary dictionaryWithDictionary:goalDict];
        [modGoalDict setObject:[goalDict objectForKey:@"id"] forKey:@"serverId"];
        [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:username];
    }
    
    self.goalObjects = [NSMutableArray arrayWithArray:[[(User *)[User MR_findFirstByAttribute:@"username" withValue:username] goals] allObjects]];
    
    self.title = @"Your Goals";
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self resetAllLocalNotifications];
    [self.tableView reloadData];
}

- (void)resetAllLocalNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    for (Goal *goal in self.goalObjects) {
        NSDate *emergencyTime;
        NSDate *wrongLaneTime;
        if ([goal.slug isEqualToString:@"weightstable"]) {
            emergencyTime = [[NSDate date]
                         dateByAddingTimeInterval:20];
            wrongLaneTime = [[NSDate date] dateByAddingTimeInterval:10];
        }
        else {
            double countdown = [goal.countdown doubleValue];
            emergencyTime = [NSDate dateWithTimeIntervalSince1970:countdown - 24*3600];
            wrongLaneTime = [NSDate dateWithTimeIntervalSince1970:countdown - 48*3600];
        }
        UIApplication* app = [UIApplication sharedApplication];
        UILocalNotification* notifyAlarm = [[UILocalNotification alloc] init];
        if (notifyAlarm)
        {
            notifyAlarm.fireDate = emergencyTime;
            notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
            notifyAlarm.repeatInterval = 0;
            notifyAlarm.alertBody = [NSString stringWithFormat:@"Emergency day today for %@!", goal.title];
            [app scheduleLocalNotification:notifyAlarm];
            
            notifyAlarm = [[UILocalNotification alloc] init];
            notifyAlarm.fireDate = wrongLaneTime;
            notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
            notifyAlarm.repeatInterval = 0;
            notifyAlarm.alertBody = [NSString stringWithFormat:@"In the wrong lane for %@!", goal.title];
            [app scheduleLocalNotification:notifyAlarm];
        }
    }

}
    
- (void)failedFetch
{
    [DejalBezelActivityView removeViewAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch goals" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
