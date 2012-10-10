//
//  ChooseGoalTypeViewController.h
//  Beeminder
//
//  Created by Andy Brett on 7/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoadDialViewController.h"

@interface ChooseGoalTypeViewController : UITableViewController

@property (nonatomic, strong) NSArray *goalTypes;
@property (nonatomic, strong) NSIndexPath *selectedAccessoryIndexPath;

- (NSUInteger)supportedInterfaceOrientations;

@end
