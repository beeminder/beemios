//
//  GoalsTableViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoalViewController.h"
#import "GoalSummaryViewController.h"
#import "Goal+Resource.h"
#import "User+Resource.h"

@interface GoalsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *goals;
@property (strong, nonatomic) NSMutableArray *goalObjects;
@end
