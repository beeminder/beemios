//
//  GalleryViewController.m
//  Beeminder
//
//  Created by Andy Brett on 12/7/13.
//  Copyright (c) 2013 Andy Brett. All rights reserved.
//

#import "GalleryViewController.h"
#import "GoalSummaryViewController.h"
#import "SignInViewController.h"

@interface GalleryViewController ()

@end

@implementation GalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"your-goals-tab"] style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarView];

    self.goalsTableView.delegate = self;
    self.goalsTableView.dataSource = self;
    self.goalsTableView.separatorColor = [UIColor clearColor];
    
    self.tabBarController.tabBar.backgroundImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0f];
    self.tabBarController.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0f];
    
    self.hasCompletedDataFetch = NO;
    
    [BeeminderAppDelegate requestPushNotificationAccess];
    
    self.pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.goalsTableView];
    [self.pull setDelegate:self];

    [self.goalsTableView addSubview:self.pull];
    
    self.goalsTableView.rowHeight = 92.0f;
    self.goalsTableView.backgroundColor = [BeeminderAppDelegate cloudsColor];
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
    [self.goalsTableView setSectionFooterHeight:[self.goalsTableView cellForRowAtIndexPath:[[NSIndexPath alloc] initWithIndex:0]].frame.size.height];
    
    User *user = [ABCurrentUser user];
    
    NSArray *arrayOfGoalObjects = [[user.goals allObjects] sortedArrayUsingComparator:self.goalComparator];
    self.goalObjects = [NSMutableArray arrayWithArray:arrayOfGoalObjects];
    
    self.frontburnerGoalObjects = [NSMutableArray arrayWithArray:[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"frontburner"];
    }]]];
    
    self.backburnerGoalObjects = [NSMutableArray arrayWithArray:[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"backburner"];
    }]]];
    
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings"]];
    view.userInteractionEnabled = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showSettings)];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kGoToGoalWithSlugKey]) {
        [self goToGoalWithSlug:[[NSUserDefaults standardUserDefaults] objectForKey:kGoToGoalWithSlugKey]];
    }
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25,0, 227, 32)];
    self.titleLabel.text = @"Your Goals";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = self.titleLabel;
    
    [self fetchEverything];
}

- (void)showSettings
{
    [self performSegueWithIdentifier:@"segueToSettings" sender:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![ABCurrentUser username]) {
        SignInViewController *signInViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"signInViewController"];
        [self presentViewController:signInViewController animated:NO completion:nil];
        return;
    }
}

- (void)goToGoalWithSlug:(NSString *)slug
{
    NSIndexSet *set = [self.goalObjects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Goal *goal = (Goal *)obj;
        return [goal.slug isEqualToString:slug];
    }];
    
    [set lastIndex];
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:[set lastIndex] inSection:0];
    
    [self.goalsTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self performSegueWithIdentifier:@"segueToGoalSummaryView" sender:self];
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self performSelectorInBackground:@selector(fetchEverything) withObject:nil];
}

- (IBAction)refreshPressed:(UIBarButtonItem *)sender
{
    [self fetchEverything];
}

- (void)fetchEverything
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator startAnimating];
    
    int lastUpdatedAt = [ABCurrentUser lastUpdatedAt];
    
    [ABCurrentUser setLastUpdatedAtToNow];
    MBProgressHUD *hud;
    BOOL initialImport = (!lastUpdatedAt || lastUpdatedAt == 0);
    if (initialImport) {
        User *user = [ABCurrentUser user];
        for (Goal *goal in user.goals) {
            [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
        }
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Fetching Beeswax...";
        hud.labelFont = [UIFont fontWithName:@"Lato" size:14.0f];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"associations", @"3", @"datapoints_count", [NSNumber numberWithInt:lastUpdatedAt], @"diff_since", [ABCurrentUser accessToken], @"access_token", nil];
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager GET:[NSString stringWithFormat:@"%@/users/me.json", kAPIPrefix] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (initialImport) {
            hud.mode = MBProgressHUDModeDeterminate;
            hud.progress = 0.0f;
            hud.labelText = @"Importing Beeswax...";
            hud.labelFont = [UIFont fontWithName:@"Lato" size:14.0f];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self successfulFetchEverythingJSON:responseObject progressCallback:^(float incrementBy){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (initialImport) [hud setProgress:hud.progress + incrementBy];
                    [self.goalsTableView reloadData];
                });
            }];
            for (Goal *goal in self.goalObjects) {
                [goal updateGraphImageThumb];
            }
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self failedFetch];
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.frontburnerGoalObjects.count;
    }
    return self.backburnerGoalObjects.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
        view.backgroundColor = [BeeminderAppDelegate silverColor];
        return view;
    }
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 1 &&
        indexPath.row >= self.backburnerGoalObjects.count) {
        //        cell.textLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
        //        cell.textLabel.text = @"Add New Goal";
        //        cell.detailTextLabel.text = @"";
    }
    else {
        if (self.goalObjects.count > 0) {
            Goal *goal;
            if (indexPath.section == 0) {
                goal = [self.frontburnerGoalObjects objectAtIndex:indexPath.row];
            }
            else {
                goal = [self.backburnerGoalObjects objectAtIndex:indexPath.row];
            }
            cell.textLabel.text = goal.title;
            cell.textLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.minimumScaleFactor = 0.5f;
            cell.detailTextLabel.text = [goal losedateTextBrief:YES];
            cell.detailTextLabel.textColor = goal.losedateColor;
            cell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Bold" size:15.0f];
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
            cell.backgroundColor = [BeeminderAppDelegate silverColor];
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segueToGoalSummaryView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToSettings"]) {
        return;
    }
    else {
        NSIndexPath *path = [self.goalsTableView indexPathForSelectedRow];
        Goal *goalObject;
        if (path.section == 0) {
            goalObject = [self.frontburnerGoalObjects objectAtIndex:path.row];
        }
        else {
            goalObject = [self.backburnerGoalObjects objectAtIndex:path.row];
        }
        
        GoalSummaryViewController *gsvCon = (GoalSummaryViewController *)segue.destinationViewController;
        [gsvCon setTitle:goalObject.title];
        [gsvCon setGoalObject:goalObject];
        [gsvCon setNeedsFreshData:!self.hasCompletedDataFetch || [[NSUserDefaults standardUserDefaults] objectForKey:kGoToGoalWithSlugKey]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGoToGoalWithSlugKey];
    }
}

- (void)successfulFetchEverythingJSON:(NSDictionary *)responseJSON progressCallback:(void(^)(float incrementBy))progressCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pull finishedLoading];
    });
    
    NSArray *deletedGoals = [responseJSON objectForKey:@"deleted_goals"];
    
    for (NSDictionary *goalDict in deletedGoals) {
        Goal *goal = [Goal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"serverId = %@", [goalDict objectForKey:@"id"]] inContext:[NSManagedObjectContext MR_defaultContext]];
        if (goal) [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
    }
    
    NSArray *goals = [responseJSON objectForKey:@"goals"];
    
    [self.goalObjects removeAllObjects];
    [self.frontburnerGoalObjects removeAllObjects];
    [self.backburnerGoalObjects removeAllObjects];
    
    for (NSDictionary *goalDict in goals) {
        progressCallback(1.0f/[goals count]);
        
        NSDictionary *modGoalDict = [Goal processGoalDictFromServer:goalDict];
        
        Goal *goal = [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];
        [self.goalObjects addObject:goal];
    }
    User *user = [ABCurrentUser user];
    [self.goalObjects removeAllObjects];
    [self.frontburnerGoalObjects removeAllObjects];
    [self.backburnerGoalObjects removeAllObjects];
    
    NSArray *arrayOfGoalObjects = [[user.goals allObjects] sortedArrayUsingComparator:self.goalComparator];
    self.goalObjects = [NSMutableArray arrayWithArray:arrayOfGoalObjects];
    
    self.frontburnerGoalObjects = [NSMutableArray arrayWithArray:[[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"frontburner"];
    }]] sortedArrayUsingComparator:self.goalComparator]];
    
    self.backburnerGoalObjects = [NSMutableArray arrayWithArray:[[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"backburner"];
    }]] sortedArrayUsingComparator:self.goalComparator]];
    
    [BeeminderAppDelegate updateApplicationIconBadgeCount];
    self.hasCompletedDataFetch = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kGoToGoalWithSlugKey]) {
            [self goToGoalWithSlug:[[NSUserDefaults standardUserDefaults] objectForKey:kGoToGoalWithSlugKey]];
        }
        [self.goalsTableView reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

- (void)failedFetch
{
    if (![ABCurrentUser username]) return;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch goals" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)pollUntilThumbnailURLIsPresentForGoal:(Goal *)goal withTimer:(NSTimer *)timer
{
    if (goal.thumb_url) {
        [timer invalidate];
        [goal updateGraphImageThumbWithCompletionBlock:^{
            [self.goalsTableView reloadData];
        }];
    }
    else {
        [GoalPullRequest requestForGoal:goal withSuccessBlock:^{
            if (goal.thumb_url) {
                [timer invalidate];
                [goal updateGraphImageThumbWithCompletionBlock:^{
                    [self.goalsTableView reloadData];
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
