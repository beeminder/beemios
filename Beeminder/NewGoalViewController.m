//
//  NewGoalViewController.m
//  Beeminder
//
//  Created by Andy Brett on 10/7/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "NewGoalViewController.h"

@interface NewGoalViewController ()

@end

@implementation NewGoalViewController

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
