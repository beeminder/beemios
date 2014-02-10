//
//  GalleryViewController.h
//  Beeminder
//
//  Created by Andy Brett on 12/7/13.
//  Copyright (c) 2013 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryViewController : UIViewController<PullToRefreshViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *goalsTableView;

@property (strong, nonatomic) NSMutableArray *goalObjects;
@property (strong, nonatomic) NSMutableArray *frontburnerGoalObjects;
@property (strong, nonatomic) NSMutableArray *backburnerGoalObjects;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSComparator goalComparator;
- (NSUInteger)supportedInterfaceOrientations;
@property (strong, nonatomic) PullToRefreshView *pull;
- (void)fetchEverything;
@property BOOL hasCompletedDataFetch;
@property (strong, nonatomic) UILabel *titleLabel;

@end
