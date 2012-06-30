//
//  GoalSummaryViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalSummaryViewController.h"


@interface GoalSummaryViewController ()

@end

@implementation GoalSummaryViewController
@synthesize unitsLabel;
@synthesize instructionLabel;
@synthesize inputTextField;
@synthesize inputStepper;
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
    }
    
    self.goalObject = [Goal findBySlug:self.slug forUserWithUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]  withContext:[self managedObjectContext]];
    
    if ([self.goalObject.units isEqualToString:@"times"]) {
        self.inputStepper.hidden = YES;
        self.inputTextField.hidden = YES;
        self.instructionLabel.text = @"Check off this goal:";
    }
    else {
        if (self.goalObject.units) {
            self.unitsLabel.text = self.goalObject.units;
        }
        self.inputTextField.text = [NSString stringWithFormat:@"%f", self.inputStepper.value];
    }
}

- (IBAction)inputStepperValueChanged
{
    self.inputTextField.text = [NSString stringWithFormat:@"%f", self.inputStepper.value];
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
    [self setUnitsLabel:nil];
    [self setInstructionLabel:nil];
    [self setInputTextField:nil];
    [self setInputStepper:nil];
    [super viewDidUnload];
}
@end
