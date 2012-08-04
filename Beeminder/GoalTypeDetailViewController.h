//
//  GoalTypeDetailViewController.h
//  Beeminder
//
//  Created by Andy Brett on 8/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseGoalTypeViewController.h"

@interface GoalTypeDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *goalTypeDetailsLabel;
@property (strong, nonatomic) NSString *detailText;
@end
