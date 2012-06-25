//
//  GoalsTableViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/18/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJson.h"

@interface GoalsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableData *responseData;
@property NSInteger responseStatus;
@property (strong, nonatomic) NSMutableArray *goals;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
