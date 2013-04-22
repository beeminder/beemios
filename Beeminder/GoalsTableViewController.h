//
//  GoalsTableViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoalSummaryViewController.h"
#import "Goal+Resource.h"
#import "User+Resource.h"
#import "PullToRefreshView.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface GoalsTableViewController : UITableViewController<PullToRefreshViewDelegate>

@property (strong, nonatomic) NSMutableArray *goalObjects;
@property (strong, nonatomic) NSMutableArray *frontburnerGoalObjects;
@property (strong, nonatomic) NSMutableArray *backburnerGoalObjects;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSComparator goalComparator;
- (NSUInteger)supportedInterfaceOrientations;
@property (strong, nonatomic) PullToRefreshView *pull;
- (void)fetchEverything;
@property BOOL hasCompletedDataFetch;
@property (strong, nonatomic) UILabel *titleLabel;

@end
