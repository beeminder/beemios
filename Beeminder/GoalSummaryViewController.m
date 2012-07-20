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
@synthesize dataSavedLabel = _dataSavedLabel;
@synthesize unitsLabel = _unitsLabel;
@synthesize instructionLabel = _instructionLabel;
@synthesize inputTextField = _inputTextField;
@synthesize inputStepper = _inputStepper;
@synthesize submitButton = _submitButton;
@synthesize graphButton = _graphButton;

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
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Fetching graph..."];
        [self.graphButton setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2.5)];
    }
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    self.goalObject = [Goal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"slug = %@ and user.username = %@", self.slug, username]];
    
    if ([self.goalObject.gtype isEqualToString:@"hustler"]) {
        self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];        
        if ([self.goalObject.units isEqualToString:@"times"]) {
//            self.inputStepper.hidden = YES;
//            self.inputTextField.hidden = YES;
//            self.unitsLabel.hidden = YES;
//            self.instructionLabel.text = @"Check off this goal:";
        }
        if (self.goalObject.units) {
            self.unitsLabel.text = self.goalObject.units;            
        }
    }
    else {
        self.inputStepper.hidden = YES;
        self.inputTextField.hidden = YES;
        self.unitsLabel.hidden = YES;
        self.instructionLabel.hidden = YES;
        self.submitButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.graphURL) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.graphURL]];
        self.graphImage = [[UIImage alloc] initWithData:imageData];
        [self.graphButton setBackgroundImage:self.graphImage forState:UIControlStateNormal];
        [DejalBezelActivityView removeViewAnimated:YES];
    }
}

- (IBAction)inputStepperValueChanged
{
    self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];
}

- (IBAction)submitButtonPressed
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *authenticationToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@/datapoints.json", kBaseURL, kAPIPrefix, username, self.goalObject.slug]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"auth_token=%@&value=%f&measured_at=%i", authenticationToken, self.inputStepper.value, (int)[[NSDate date]timeIntervalSince1970]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.dataSavedLabel.hidden = NO;
        [DejalBezelActivityView removeViewAnimated:YES];
        if (JSON) {
            //foo
        }
            
    } failure:nil];
    [operation start];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Saving..."];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GoalGraphViewController *ggvCon = (GoalGraphViewController *)segue.destinationViewController;
    ggvCon.graphImage = self.graphImage;
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
    [self setSubmitButton:nil];
    [self setDataSavedLabel:nil];
    [super viewDidUnload];
}

@end
