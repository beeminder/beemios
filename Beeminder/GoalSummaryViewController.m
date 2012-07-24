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
@synthesize timerLabel = _timerLabel;
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
        [self.graphButton setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2.5)];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authenticationToken = [defaults objectForKey:@"authenticationTokenKey"];
    
    NSString *username = [defaults objectForKey:@"username"];
    
    NSURL *goalUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/users/%@/goals/%@.json?auth_token=%@&datapoints=true", kBaseURL, username, self.slug, authenticationToken]];
    
    NSMutableURLRequest *goalRequest = [NSMutableURLRequest requestWithURL:goalUrl];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:goalRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulGoalFetchJSON:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self failedDatapointsFetch];
    }];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Fetching data..."];
    [operation start];
    
    self.goalObject = [Goal MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"slug = %@ and user.username = %@", self.slug, username]];
    
    self.unitsLabel.text = self.goalObject.units;
    
    if ([self.goalObject.gtype isEqualToString:@"hustler"] && [self.goalObject.units isEqualToString:@"times"]) {
        self.inputStepper.hidden = YES;
        self.inputTextField.hidden = YES;
        self.unitsLabel.hidden = YES;
        self.instructionLabel.text = @"Check off this goal:";
    }

    self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadGraphImage];
}

- (void)loadGraphImage
{
    if (self.graphURL) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.graphURL]];
        self.graphImage = [[UIImage alloc] initWithData:imageData];
        [self.graphButton setBackgroundImage:self.graphImage forState:UIControlStateNormal];
    }
}

- (void)successfulGoalFetchJSON:(id)responseJSON
{
    [DejalBezelActivityView removeView];
    self.goalObject.datapoints = [[NSSet alloc] init];
    for (NSDictionary *datapointDict in [responseJSON objectForKey:@"datapoints"]) {
        // add datapoints to goal - nuke all existing.
        NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
        Datapoint *datapoint = [Datapoint MR_createInContext:defaultContext];
        datapoint.value = [datapointDict objectForKey:@"value"];
        datapoint.comment = [datapointDict objectForKey:@"comment"];
        datapoint.timestamp = [datapointDict objectForKey:@"timestamp"];
        datapoint.goal = self.goalObject;
        [defaultContext MR_save];
    }
    
    NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseJSON];
    
    [mutableResponse removeObjectForKey:@"datapoints"];
    
    [Goal writeToGoalWithDictionary:mutableResponse forUserWithUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    
    if (![self.goalObject.gtype isEqualToString:@"hustler"]) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"goal = %@", self.goalObject];
        
        Datapoint *datapoint = [Datapoint MR_findFirstWithPredicate:pred sortedBy:@"timestamp" ascending:NO];

        self.inputStepper.value = [datapoint.value doubleValue];
        self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];
    }
    [self startTimer];
}

- (void)failedDatapointsFetch
{
    
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
    
    NSString *postString = [NSString stringWithFormat:@"auth_token=%@&value=%f&timestamp=%i", authenticationToken, self.inputStepper.value, (int)[[NSDate date]timeIntervalSince1970]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if ([JSON objectForKey:@"success"]) {
            [self loadGraphImage];            
            [DejalBezelActivityView currentActivityView].activityLabel.text = @"Saved";
        }
        else {
            [DejalBezelActivityView currentActivityView].activityLabel.text = @"Error";            
        }
        [DejalBezelActivityView currentActivityView].activityIndicator.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [DejalBezelActivityView removeViewAnimated:YES];
        });            
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [DejalBezelActivityView removeViewAnimated:YES];
    }];
    [operation start];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Saving..."];
}

- (void)updateTimer
{
    uint seconds = (uint)[[NSDate dateWithTimeIntervalSince1970:[self.goalObject.countdown doubleValue]] timeIntervalSinceNow];
    
    if (seconds > 0) {
        
        int hours = (seconds % (3600*24))/3600;
        int minutes = (seconds % 3600)/60;
        int leftoverSeconds = seconds % 60;
        int days = seconds/(3600*24);
        
        if (days > 0) {
            self.timerLabel.text = [NSString stringWithFormat:@"%i days, %i:%02i:%02i", days, hours, minutes,leftoverSeconds];
        }
        else {
            self.timerLabel.text = [NSString stringWithFormat:@"%i:%02i:%02i", hours, minutes,leftoverSeconds];
        }

    }
    else {
        self.timerLabel.text = [NSString stringWithFormat:@"Time's up!"];
    }
}

- (IBAction)startTimer {
    [self updateTimer];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
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
    [self setTimerLabel:nil];
    [super viewDidUnload];
}

@end
