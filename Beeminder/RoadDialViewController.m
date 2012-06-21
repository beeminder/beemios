//
//  RoadDialViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "RoadDialViewController.h"

@interface RoadDialViewController ()

@end

@implementation RoadDialViewController

@synthesize introLabel = _introLabel;
@synthesize currentValue = _currentValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = self.goalType;
    if ([self.goalType isEqualToString:@"Lose Weight"]) {
        self.introLabel.text = @"Lose Weight Text";
    }
    else if ([self.goalType isEqualToString:@"Do More"]) {
        self.introLabel.text = @"Do More Text";
    }
    else {
        [self.currentValue removeFromSuperview];
    }
    // TODO: store these in Core Data
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setIntroLabel:nil];
    [self setCurrentValue:nil];
    [self setCurrentValue:nil];
    [super viewDidUnload];
}
@end
