//
//  GoalSummaryViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalSummaryViewController.h"
#import "GoalGraphViewController.h"

@interface GoalSummaryViewController ()

@end

@implementation GoalSummaryViewController
@synthesize graphButton;

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
        [self.graphButton setBackgroundImage:[[UIImage alloc] initWithData:imageData] forState:UIControlStateNormal];
        [self.graphButton setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2.5)];
        
//        [self.imageView setFrame:self.view.frame];
//        [self.imageView setImage:[[UIImage alloc] initWithData:imageData]];
    }
    
    self.goalObject = [Goal findBySlug:self.slug forUserWithUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]  withContext:[self managedObjectContext]];
    
    if (YES) {//([self.goalObject.units isEqualToString:@"times"]) {
        [self addCheckinButton];
    }
                       
}

- (void)addCheckinButton
{
    CGRect buttonRect = CGRectMake(self.view.frame.size.width/3, self.view.frame.size.height/2.5, self.view.frame.size.width/3, self.view.frame.size.height/8);

    UIButton *checkinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    checkinButton.frame = buttonRect;
    [checkinButton setTitle:@"Done!" forState:UIControlStateNormal];
    
    [self.view addSubview:checkinButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GoalGraphViewController *ggvCon = (GoalGraphViewController *)segue.destinationViewController;
    ggvCon.graphURL = self.graphURL;
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
    [self setGraphButton:nil];
    [super viewDidUnload];
}
@end
