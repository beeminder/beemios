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

@interface GoalsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *goalObjects;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSComparator goalComparator;

@end
