//
//  RoadDialViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Goal+Resource.h"
#import "GoalsTableViewController.h"
#import "AdvancedRoadDialViewController.h"
#import "ChooseGoalTypeViewController.h"

@interface RoadDialViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *goalTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *goalDetailsLabel;
@property (strong, nonatomic) IBOutlet UITextField *firstTextField;
@property (strong, nonatomic) IBOutlet UILabel *firstLabel;
@property (strong, nonatomic) IBOutlet UISwitch *startFlatSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *ephemSwitch;
@property (strong, nonatomic) IBOutlet UIButton *roadDialButton;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSArray *goalSlugs;
@property (strong, nonatomic) IBOutlet UIButton *saveGoalButton;
@property (strong, nonatomic) IBOutlet UILabel *goalSlugExistsWarningLabel;
@property (strong, nonatomic) IBOutlet UILabel *startFlatLabel;
- (NSUInteger)supportedInterfaceOrientations;
@end
