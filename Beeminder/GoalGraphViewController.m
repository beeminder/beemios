//
//  GoalGraphViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalGraphViewController.h"

@interface GoalGraphViewController ()

@end

@implementation GoalGraphViewController
@synthesize graphImageView;

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
    if (self.graphURL) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.graphURL]];
        [self.graphImageView setFrame:self.view.frame];
        [self.graphImageView setImage:[[UIImage alloc] initWithData:imageData]];
    }

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
    [self setGraphImageView:nil];
    [super viewDidUnload];
}
@end
