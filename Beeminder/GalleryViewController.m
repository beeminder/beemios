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

@property BOOL isUpdating;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UILabel *lastUpdatedLabel;

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedOut) name:@"signedOut" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedIn) name:@"signedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goalUpdated:) name:@"goalUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllGoals) name:@"reloadAllGoals" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchEverything) name:@"fetchEverything" object:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"your-goals-tab"] style:UIBarButtonItemStylePlain target:self action:@selector(fetchEverything)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.lastUpdatedLabel = [[UILabel alloc] init];
    [self.view addSubview:self.lastUpdatedLabel];

    self.lastUpdatedLabel.font = [UIFont defaultFont];
    self.lastUpdatedLabel.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
    [self.lastUpdatedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        UIView *topLayoutGuide = (id)self.topLayoutGuide;
        make.top.equalTo(topLayoutGuide.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(28);
    }];
    [self updateLastUpdatedLabel];
    
    self.goalsTableView = [[UITableView alloc] init];
    [self.view addSubview:self.goalsTableView];
    [self.goalsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastUpdatedLabel.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        UIView *bottomLayoutGuide = (id)self.bottomLayoutGuide;
        make.bottom.equalTo(bottomLayoutGuide.mas_top);
    }];
    self.goalsTableView.delegate = self;
    self.goalsTableView.dataSource = self;
    self.goalsTableView.separatorColor = [UIColor clearColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    
    [BeeminderAppDelegate requestPushNotificationAccess];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    UITableViewController *tableVC = [[UITableViewController alloc] init];
    tableVC.tableView = self.goalsTableView;
    tableVC.refreshControl = self.refreshControl;
    [self.goalsTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(fetchEverything) forControlEvents:UIControlEventValueChanged];
    
    self.goalsTableView.rowHeight = 110.0f;
    self.goalsTableView.backgroundColor = [BeeminderAppDelegate cloudsColor];
    self.goalComparator = ^(id a, id b) {
        if ([[a panicTime] doubleValue] - ([[b panicTime] doubleValue]) > 0) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedAscending;
        }
    };
    [self.goalsTableView setSectionFooterHeight:[self.goalsTableView cellForRowAtIndexPath:[[NSIndexPath alloc] initWithIndex:0]].frame.size.height];
    
    User *user = [ABCurrentUser user];
//    [self.frontburnerGoalObjects removeAllObjects];
//    [self.backburnerGoalObjects removeAllObjects];
    
    self.frontburnerGoalObjects = [NSMutableArray arrayWithArray:[[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"frontburner"];
    }]] sortedArrayUsingComparator:self.goalComparator]];
    
    self.backburnerGoalObjects = [NSMutableArray arrayWithArray:[[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"backburner"];
    }]] sortedArrayUsingComparator:self.goalComparator]];
    
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings-white"]];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *settingsTagGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSettings)];
    [view addGestureRecognizer:settingsTagGR];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
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
    
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateLastUpdatedLabel) userInfo:nil repeats:YES];
}

- (void)updateLastUpdatedLabel
{
    int diff = [[[NSDate alloc] init] timeIntervalSince1970] - [ABCurrentUser lastUpdatedAt];
    if (diff < 60) {
        self.lastUpdatedLabel.text = @"Last updated: less than a minute ago";
        self.lastUpdatedLabel.textColor = [UIColor darkTextColor];
        self.lastUpdatedLabel.font = [UIFont defaultFont];
    }
    else if (diff > 3600) {
        self.lastUpdatedLabel.text = @"Last updated: more than an hour ago";
        self.lastUpdatedLabel.textColor = [UIColor redColor];
        self.lastUpdatedLabel.font = [UIFont defaultFontBold];
    }
    else {
        if (diff/60 == 1) {
            self.lastUpdatedLabel.text = @"Last updated: 1 minute ago";
        }
        else {
            self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %d minutes ago", diff/60];
        }

        self.lastUpdatedLabel.textColor = [UIColor darkTextColor];
        self.lastUpdatedLabel.font = [UIFont defaultFont];
    }
}

- (void)goalUpdated:(NSNotification *)notification
{
    Goal *goal = [[notification userInfo] objectForKey:@"goal"];
    [goal updateGraphImageThumbWithCompletionBlock:^{
        [self.goalsTableView reloadData];
    }];
}

- (void)pollForThumbnails
{
    for (Goal *g in [ABCurrentUser user].goals) [self pollUntilThumbnailURLIsPresentForGoal:g];
}

- (void)signedOut
{
    [ABCurrentUser logout];
    [self.navigationController popToRootViewControllerAnimated:NO];
    SignInViewController *signInViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"signInViewController"];
    [self presentViewController:signInViewController animated:YES completion:nil];
}

- (void)signedIn
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self fetchEverything];
    }];
}

- (void)showSettings
{
    [self performSegueWithIdentifier:@"segueToSettings" sender:self];
}

- (void)reloadAllGoals
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    for (Goal *g in [ABCurrentUser user].goals) {
        [g MR_deleteEntity];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [ABCurrentUser resetLastUpdatedAt];
    [self fetchEverything];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![ABCurrentUser username]) {
        SignInViewController *signInViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"signInViewController"];
        [self presentViewController:signInViewController animated:NO completion:nil];
    }
}

- (void)goToGoalWithSlug:(NSString *)slug
{
    NSIndexSet *set = [self.frontburnerGoalObjects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Goal *goal = (Goal *)obj;
        return [goal.slug isEqualToString:slug];
    }];
    
    if (set.count == 0) {
        set = [self.backburnerGoalObjects indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            Goal *goal = (Goal *)obj;
            return [goal.slug isEqualToString:slug];
        }];
    }
    
    [set lastIndex];
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:[set lastIndex] inSection:0];
    
    [self.goalsTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self performSegueWithIdentifier:@"segueToGoalSummaryView" sender:self];
}

- (void)fetchEverything
{
    if (self.isUpdating) return;
    self.isUpdating = YES;
    [self.goalsTableView reloadData];
    int lastUpdatedAt = [ABCurrentUser lastUpdatedAt];
    
    MBProgressHUD *hud;
    BOOL initialImport = (!lastUpdatedAt || lastUpdatedAt == 0);
    if (initialImport) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Fetching Beeswax...";
        hud.labelFont = [UIFont fontWithName:@"Lato" size:14.0f];
    }

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"associations", @"5", @"datapoints_count", [NSNumber numberWithInt:lastUpdatedAt], @"diff_since", [ABCurrentUser accessToken], @"access_token", nil];
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager GET:[NSString stringWithFormat:@"%@/users/me.json", kAPIPrefix] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isUpdating = NO;
        if (initialImport) {
            hud.progress = 0.0f;
            hud.labelText = @"Importing Beeswax...";
            hud.labelFont = [UIFont fontWithName:@"Lato" size:14.0f];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self successfulFetchEverythingJSON:responseObject];
            for (Goal *goal in self.frontburnerGoalObjects) {
                [goal updateGraphImage];
                [goal updateGraphImageThumbWithCompletionBlock:^{
                    [self.goalsTableView reloadData];
                }];
            }
            for (Goal *goal in self.backburnerGoalObjects) {
                [goal updateGraphImage];
                [goal updateGraphImageThumbWithCompletionBlock:^{
                    [self.goalsTableView reloadData];
                }];
            }
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.isUpdating = NO;
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
    
    if (self.frontburnerGoalObjects.count > 0 || self.backburnerGoalObjects.count > 0) {
        Goal *goal;
        if (indexPath.section == 0) {
            goal = [self.frontburnerGoalObjects objectAtIndex:indexPath.row];
        }
        else {
            goal = [self.backburnerGoalObjects objectAtIndex:indexPath.row];
        }
        
        UILabel *titleLabel = [[UILabel alloc] init];
        
        titleLabel.text = goal.title;
        titleLabel.font = [UIFont defaultFontBold];
        [cell.contentView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.top.mas_equalTo(8);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        if (goal.graph_image_thumb) {
            imageView.image = goal.graph_image_thumb;
        }
        else {
            [MBProgressHUD showHUDAddedTo:imageView animated:YES];
        }
        
        [cell.contentView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.top.equalTo(titleLabel.mas_bottom).with.offset(10);
            make.width.mas_equalTo(106);
            make.height.mas_equalTo(70);
        }];

        
        UIView *losedateView = [[UIView alloc] init];
        [cell.contentView addSubview:losedateView];
        [losedateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.top.equalTo(imageView);
            make.bottom.equalTo(imageView);
            make.width.equalTo(cell.contentView).with.multipliedBy(0.22);
        }];
        if (goal.slug) {
            losedateView.backgroundColor = [goal losedateColor];
        }
        else {
            losedateView.backgroundColor = [UIColor whiteColor];
        }

        
        UILabel *loseDateLabel = [[UILabel alloc] init];
        loseDateLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18.0f];
        loseDateLabel.textAlignment = NSTextAlignmentCenter;
        [losedateView addSubview:loseDateLabel];
        [loseDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(losedateView);
        }];
        loseDateLabel.numberOfLines = 0;
        loseDateLabel.textColor = [UIColor whiteColor];
        
        if (self.isUpdating) {
            loseDateLabel.text = @"";
        }
        else if(goal.yaw && goal.delta_text) {
            loseDateLabel.text = [goal losedateTextBrief:YES];
        }
        
        UILabel *rateLabel = [[UILabel alloc] init];
        [cell.contentView addSubview:rateLabel];
        [rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right);
            make.top.equalTo(imageView);
            make.right.equalTo(losedateView.mas_left);
            make.bottom.equalTo(imageView);
        }];
        rateLabel.font = [UIFont defaultFontBold];
        rateLabel.textColor = [UIColor darkTextColor];
        rateLabel.textAlignment = NSTextAlignmentCenter;

        NSString *runitString = @"week";
        if ([goal.runits isEqualToString:@"d"]) {
            runitString = @"day";
        }
        else if ([goal.runits isEqualToString:@"m"]) {
            runitString = @"month";
        }
        else if ([goal.runits isEqualToString:@"y"]) {
             runitString = @"year";
        }
        
        NSString *rateString = @"";
        if (goal.rate) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.maximumSignificantDigits = 2;
            rateString = [formatter stringFromNumber:goal.rate];
        }

        rateLabel.text = [NSString stringWithFormat:@"%@/%@", rateString, runitString];
        
        if (goal.delta_text && goal.yaw && [[BeeminderAppDelegate attributedDeltasString:goal.delta_text yaw:goal.yaw].string stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0) {
            UILabel *deltasLabel = [[UILabel alloc] init];
            NSMutableAttributedString *deltas = [[NSMutableAttributedString alloc] initWithAttributedString:[BeeminderAppDelegate attributedDeltasString:goal.delta_text yaw:goal.yaw]];
            [deltas addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Lato-Bold" size:13.0f] range:NSMakeRange(0, deltas.length)];
            deltasLabel.attributedText = deltas;
            deltasLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:deltasLabel];
            [deltasLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(imageView.mas_right);
                make.bottom.equalTo(imageView);
                make.top.mas_equalTo(imageView.mas_centerY);
                make.right.equalTo(losedateView.mas_left);
            }];
            [rateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(imageView.mas_right);
                make.top.equalTo(imageView);
                make.right.equalTo(losedateView.mas_left);
                make.bottom.mas_equalTo(imageView.mas_centerY);
            }];
        }

        cell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Bold" size:15.0f];

        cell.backgroundColor = [BeeminderAppDelegate silverColor];
        cell.backgroundColor = [UIColor whiteColor];
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGoToGoalWithSlugKey];
    }
}

- (void)successfulFetchEverythingJSON:(NSDictionary *)responseJSON
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
    
    NSArray *deletedGoals = [responseJSON objectForKey:@"deleted_goals"];
    
    for (NSDictionary *goalDict in deletedGoals) {
        Goal *goal = [Goal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"serverId = %@", [goalDict objectForKey:@"id"]] inContext:[NSManagedObjectContext MR_defaultContext]];
        if (goal) [[NSManagedObjectContext MR_defaultContext] deleteObject:goal];
    }
    
    NSArray *goals = [responseJSON objectForKey:@"goals"];
    
    for (NSDictionary *goalDict in goals) {
        
        NSDictionary *modGoalDict = [Goal processGoalDictFromServer:goalDict];
        
        [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];
    }
    User *user = [ABCurrentUser user];
    [self.frontburnerGoalObjects removeAllObjects];
    [self.backburnerGoalObjects removeAllObjects];

    self.frontburnerGoalObjects = [NSMutableArray arrayWithArray:[[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"frontburner"];
    }]] sortedArrayUsingComparator:self.goalComparator]];
    
    self.backburnerGoalObjects = [NSMutableArray arrayWithArray:[[[user.goals allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Goal *g = (Goal *)evaluatedObject;
        return [g.burner isEqualToString:@"backburner"];
    }]] sortedArrayUsingComparator:self.goalComparator]];
    
    [BeeminderAppDelegate updateApplicationIconBadgeCount];
    [ABCurrentUser setLastUpdatedAtToNow];    
    [self pollForThumbnails];

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kGoToGoalWithSlugKey]) {
            [self goToGoalWithSlug:[[NSUserDefaults standardUserDefaults] objectForKey:kGoToGoalWithSlugKey]];
        }
        [self.goalsTableView reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self updateLastUpdatedLabel];
    });
}

- (NSIndexPath *)indexPathForGoal:(Goal *)goal
{
    NSInteger row;
    NSInteger section;
    if ([goal.burner isEqualToString:@"frontburner"]) {
        section = 0;
        row = [self.frontburnerGoalObjects indexOfObject:goal];
    }
    else {
        section = 1;
        row = [self.backburnerGoalObjects indexOfObject:goal];
    }

    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (void)pollUntilThumbnailURLIsPresentForGoal:(Goal *)goal
{
    if (goal.thumb_url) {
        [goal updateGraphImageThumbWithCompletionBlock:^{
            [self.goalsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForGoal:goal]] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    else {
        [GoalPullRequest requestForGoal:goal withSuccessBlock:^{
            if (goal.thumb_url) {
                [goal updateGraphImageThumbWithCompletionBlock:^{
                    [self.goalsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForGoal:goal]] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
            else {
                [self pollUntilThumbnailURLIsPresentForGoal:goal];
            }
        } withErrorBlock:^{
            NSLog(@"Error pulling goal from server");
        }];
    }
}

@end
