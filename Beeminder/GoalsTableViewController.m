//
//  GoalsTableViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalsTableViewController.h"
#import "AFJSONRequestOperation.h"

@interface GoalsTableViewController ()

@end

@implementation GoalsTableViewController
@synthesize refreshButton;

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
    self.tableView.rowHeight = 92.0f;
    self.goalComparator = ^(id a, id b) {
        double aBackburnerPenalty = [[a burner] isEqualToString:@"backburner"] ? 1000000000000 : 0;
        double bBackburnerPenalty = [[b burner] isEqualToString:@"backburner"] ? 1000000000000 : 0;
        if ([[a panicTime] doubleValue] + aBackburnerPenalty - ([[b panicTime] doubleValue] + bBackburnerPenalty) > 0) {
            return 1;
        }
        else {
            return -1;
        }
    };
    [self.tableView setSectionFooterHeight:[self.tableView cellForRowAtIndexPath:[[NSIndexPath alloc] initWithIndex:0]].frame.size.height];
    
    User *user = [ABCurrentUser user];

    NSArray *arrayOfGoalObjects = [[user.goals allObjects] sortedArrayUsingComparator:self.goalComparator];
    self.goalObjects = [NSMutableArray arrayWithArray:arrayOfGoalObjects];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchEverything)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    for (Goal *goal in self.goalObjects) {
        [goal updateGraphImageThumb];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![ABCurrentUser accessToken]) {
        [self failedFetch];
        return;
    }
    
    [self fetchEverything];
}

- (IBAction)refreshPressed:(UIBarButtonItem *)sender
{
    [self fetchEverything];
}

- (void)fetchEverything
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator startAnimating];    
    self.refreshButton = [[self.navigationItem rightBarButtonItem] initWithCustomView:self.activityIndicator];
    
    if (![ABCurrentUser accessToken]) {
        [self failedFetch];
        return;
    }
    
    NSString *username = [ABCurrentUser username];
    int lastUpdatedAt = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastUpdatedAt"];

    NSURL *fetchUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@.json?associations=true&diff_since=%d&access_token=%@", kBaseURL, kAPIPrefix, username, lastUpdatedAt, [ABCurrentUser accessToken]]];
    
    NSURLRequest *fetchRequest = [NSURLRequest requestWithURL:fetchUrl];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(int)[[NSDate date] timeIntervalSince1970] forKey:@"lastUpdatedAt"];
    MBProgressHUD *hud;
    if (!lastUpdatedAt || lastUpdatedAt == 0) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //    hud.progress = 0.0;
        //    hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.labelText = @"Importing Beeswax";
    }

    AFJSONRequestOperation *fetchOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:fetchRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulFetchEverythingJSON:JSON hud:hud];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self failedFetch];
    }];

    [fetchOperation start];
}

- (void)viewDidUnload
{
    [self setRefreshButton:nil];
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
    return [self.goalObjects count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Goal Cell";
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (indexPath.row >= self.goalObjects.count) {
        cell.textLabel.text = @"Add New Goal";
        cell.detailTextLabel.text = @"";
    }
    else {
        if (self.goalObjects.count > 0) {
            Goal *goal = [self.goalObjects objectAtIndex:indexPath.row];
            cell.textLabel.text = goal.title;
            cell.detailTextLabel.text = [goal losedateTextBrief:YES];
            cell.detailTextLabel.textColor = goal.losedateColor;
            cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
            cell.indentationLevel = 3.0;
            cell.indentationWidth = 40.0;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 106, 70)];
            if (goal.graph_image_thumb) {
                imageView.image = goal.graph_image_thumb;
            }
            else {
                [MBProgressHUD showHUDAddedTo:imageView animated:YES];
            }

            [cell addSubview:imageView];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.goalObjects.count) {
        [self performSegueWithIdentifier:@"segueToAddGoal" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"segueToGoalSummaryView" sender:self];
    }
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

- (void)successfulFetchEverythingJSON:(NSDictionary *)responseJSON hud:(MBProgressHUD *)hud
{
    [self.activityIndicator stopAnimating];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchEverything)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
    NSArray *goals = [responseJSON objectForKey:@"goals"];
    
    [self.goalObjects removeAllObjects];
    
    for (NSDictionary *goalDict in goals) {
        hud.progress += 1.0/goals.count;
        NSMutableDictionary *modGoalDict = [NSMutableDictionary dictionaryWithDictionary:goalDict];
        [modGoalDict setObject:[goalDict objectForKey:@"id"] forKey:@"serverId"];
        [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];
    }
    
    User *user = [ABCurrentUser user];

    NSArray *arrayOfGoalObjects = [[user.goals allObjects] sortedArrayUsingComparator:self.goalComparator];
    self.goalObjects = [NSMutableArray arrayWithArray:arrayOfGoalObjects];
    
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
        double losedate = [goal.losedate doubleValue]; 
        emergencyTime = [NSDate dateWithTimeIntervalSince1970:losedate - 24*3600];
        wrongLaneTime = [NSDate dateWithTimeIntervalSince1970:losedate - 48*3600];

        UIApplication* app = [UIApplication sharedApplication];
        UILocalNotification* notifyAlarm = [[UILocalNotification alloc] init];
        if (notifyAlarm && losedate > [[NSDate date] timeIntervalSince1970])
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.activityIndicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch goals" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)refreshThumbnails
{
    for (Goal *goal in self.goalObjects) {
        [goal updateGraphImages];
    }
}

@end
