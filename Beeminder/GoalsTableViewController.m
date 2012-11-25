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
    NSLog(@"load");
    [self fetchEverything];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![ABCurrentUser accessToken]) {
        [self failedFetch];
        return;
    }
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

    NSURL *fetchUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@.json?associations=true&diff_since=%d&skinny=true&access_token=%@", kBaseURL, kAPIPrefix, username, lastUpdatedAt, [ABCurrentUser accessToken]]];
    
    NSURLRequest *fetchRequest = [NSURLRequest requestWithURL:fetchUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:300];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(int)[[NSDate date] timeIntervalSince1970] forKey:@"lastUpdatedAt"];
    MBProgressHUD *hud;
    BOOL initialImport = (!lastUpdatedAt || lastUpdatedAt == 0);
    if (initialImport) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Fetching Beeswax...";
    }

    AFJSONRequestOperation *fetchOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:fetchRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (initialImport) {
            hud.mode = MBProgressHUDModeDeterminate;
            hud.progress = 0.0f;
            hud.labelText = @"Importing Beeswax...";
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self successfulFetchEverythingJSON:JSON progressCallback:^(float incrementBy){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (initialImport) [hud setProgress:hud.progress + incrementBy];
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
                [self pollUntilThumbnailURLIsPresentForGoal:goal withTimer:nil];
            }

            [cell addSubview:imageView];

            if ([goal.burner isEqualToString:@"frontburner"]) {
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell-noise"]];
            }
            else {
                cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark-cell-noise"]];
            }
        }
    }
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
        [self replaceRefreshButton];
    });
    
    NSArray *deletedGoals = [responseJSON objectForKey:@"deleted_goals"];
    
    for (NSDictionary *goalDict in deletedGoals) {
        Goal *goal = [Goal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"serverId = %@", [goalDict objectForKey:@"id"]] inContext:[NSManagedObjectContext MR_defaultContext]];
        if (goal) [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
    }
    
    NSArray *goals = [responseJSON objectForKey:@"goals"];
    
    [self.goalObjects removeAllObjects];
    
    for (NSDictionary *goalDict in goals) {
        progressCallback(1.0f/[goals count]);
        NSMutableDictionary *modGoalDict = [NSMutableDictionary dictionaryWithDictionary:goalDict];
        [modGoalDict setObject:[goalDict objectForKey:@"id"] forKey:@"serverId"];
        NSString *runits = [goalDict objectForKey:@"runits"];
        NSNumber *weeklyRate;
        if ([goalDict objectForKey:@"rate"] != (id)[NSNull null]) {

            if ([runits isEqualToString:@"y"]) {
                weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]/52];
            }
            else if ([runits isEqualToString:@"m"]) {
                weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]/4];
            }
            else if ([runits isEqualToString:@"d"]) {
                weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]*7];
            }
            else if ([runits isEqualToString:@"h"]) {
                weeklyRate = [NSNumber numberWithDouble:[[goalDict objectForKey:@"rate"] doubleValue]*7*24];
            }
            else {
                weeklyRate = [goalDict objectForKey:@"rate"];
            }
            [modGoalDict setObject:weeklyRate forKey:@"rate"];
        }
        
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
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

- (void)replaceRefreshButton
{
    [self.activityIndicator stopAnimating];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchEverything)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
}
    
- (void)failedFetch
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self replaceRefreshButton];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch goals" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)pollUntilThumbnailURLIsPresentForGoal:(Goal *)goal withTimer:(NSTimer *)timer
{
    if (goal.thumb_url) {
        [timer invalidate];
        [goal updateGraphImageThumbWithCompletionBlock:^{
            [self.tableView reloadData];
        }];
    }
    else {
        [GoalPullRequest requestForGoal:goal withSuccessBlock:^{
            if (goal.thumb_url) {
                [timer invalidate];
                [goal updateGraphImageThumbWithCompletionBlock:^{
                    [self.tableView reloadData];
                }];
            }
            else {
                [self pollUntilThumbnailURLIsPresentForGoal:goal withTimer:timer];
            }
        } withErrorBlock:^{
            NSLog(@"Error pulling goal from server");
        }];
    }
}

@end
