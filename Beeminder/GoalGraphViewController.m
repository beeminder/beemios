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
@synthesize graphImage = _graphImage;
@synthesize scrollView;

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
    if (self.graphImage) {
        [self.graphImageView setFrame:self.view.frame];
        [self.graphImageView setImage:self.graphImage];
        self.scrollView.minimumZoomScale = 0.5;
        self.scrollView.maximumZoomScale = 6.0;
        self.scrollView.clipsToBounds = YES;
        self.scrollView.contentSize = self.view.frame.size;
        self.scrollView.delegate = self;
    }

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.graphImageView setFrame:self.view.frame];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.height, self.view.frame.size.width);
}

- (void)viewDidUnload
{
    [self setGraphImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphImageView;
}

@end
