//
//  ChooseGoalTypeViewController.m
//  Beeminder
//
//  Created by Andy Brett on 7/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ChooseGoalTypeViewController.h"

@interface ChooseGoalTypeViewController ()

@end

@implementation ChooseGoalTypeViewController

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
    
    [BeeminderAppDelegate clearSessionGoal];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-noise"]];
    self.goalTypes = [[NSArray alloc] init];
    NSDictionary *goalTypesInfo = [BeeminderAppDelegate goalTypesInfo];

    [goalTypesInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        self.goalTypes = [self.goalTypes arrayByAddingObject:obj];
    }];

    self.goalTypes = [self.goalTypes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 objectForKey:kSortPriorityKey] doubleValue] > [[obj2 objectForKey:kSortPriorityKey] doubleValue];
    }];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(80, 30, 160, 50);
    button = [BeeminderAppDelegate standardGrayButtonWith:button];
    button.userInteractionEnabled = YES;
    footerView.userInteractionEnabled = YES;
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    
    [button addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:button];
    
    self.tableView.tableFooterView = footerView;
    self.tableView.tableFooterView.userInteractionEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.goalTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Goal Type Cell"];
    NSDictionary *goalTypeInfo = [self.goalTypes objectAtIndex:indexPath.row];
    cell.textLabel.text = [goalTypeInfo objectForKey:@"publicName"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [BeeminderAppDelegate sharedSessionGoal].goal_type = [[self.goalTypes objectAtIndex:indexPath.row] objectForKey:kPrivateNameKey];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
