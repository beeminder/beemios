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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 92.0f;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-noise"]];
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
        hud.labelText = @"Fetching Beeswax...";
    }

    AFJSONRequestOperation *fetchOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:fetchRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (!lastUpdatedAt || lastUpdatedAt == 0) {
            hud.mode = MBProgressHUDModeDeterminate;
            hud.progress = 0.0f;
            hud.labelText = @"Importing Beeswax...";
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self successfulFetchEverythingJSON:JSON progressCallback:^(float incrementBy){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud setProgress:hud.progress + incrementBy];
                    [self.tableView reloadData];
                });
            }];
        });


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
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-noise"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.goalObjects.count) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UINavigationController *newGoalNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"newGoalNavigationController"];
        [self presentViewController:newGoalNavigationController animated:YES completion:nil];
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

- (void)successfulFetchEverythingJSON:(NSDictionary *)responseJSON progressCallback:(void(^)(float incrementBy))progressCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchEverything)];
        self.navigationItem.rightBarButtonItem = self.refreshButton;
    });
    
    NSArray *goals = [responseJSON objectForKey:@"goals"];
    
    [self.goalObjects removeAllObjects];
    
    for (NSDictionary *goalDict in goals) {
        progressCallback(1.0f/[goals count]);
        NSMutableDictionary *modGoalDict = [NSMutableDictionary dictionaryWithDictionary:goalDict];
        [modGoalDict setObject:[goalDict objectForKey:@"id"] forKey:@"serverId"];
        Goal *goal = [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];
        [self.goalObjects addObject:goal];
    }
    User *user = [ABCurrentUser user];
    [self.goalObjects removeAllObjects];
    
    NSArray *arrayOfGoalObjects = [[user.goals allObjects] sortedArrayUsingComparator:self.goalComparator];
    self.goalObjects = [NSMutableArray arrayWithArray:arrayOfGoalObjects];
    
    self.title = @"Your Goals";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self refreshThumbnails];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self resetAllLocalNotifications];
    }); 
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
        [goal updateGraphImageThumbWithCompletionBlock:^{
            [self.goalObjects removeAllObjects];
            User *user = [ABCurrentUser user];
            NSArray *arrayOfGoalObjects = [[user.goals allObjects] sortedArrayUsingComparator:self.goalComparator];
            self.goalObjects = [NSMutableArray arrayWithArray:arrayOfGoalObjects];
            [self.tableView reloadData];
        }];
    }
}

@end
