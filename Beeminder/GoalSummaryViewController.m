//
//  GoalSummaryViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalSummaryViewController.h"
#import "AdvancedRoadDialViewController.h"

@interface GoalSummaryViewController ()

@end

@implementation GoalSummaryViewController
@synthesize scrollView = _scrollView;
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
    
    self.inputTextField.keyboardType = UIKeyboardTypeDecimalPad;

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
    
    if (self.goalObject.units) {
        self.unitsLabel.text = self.goalObject.units;
    }

    self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];
    [self registerForKeyboardNotifications];    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadGraphImage];
}

- (void)loadGraphImage
{
    if (self.graphURL) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.graphURL] options:NSDataReadingUncached error:nil];
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
        datapoint.serverId = [datapointDict objectForKey:@"id"];
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
- (IBAction)inputTextFieldValueChanged
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.inputStepper.value = [[numberFormatter numberFromString:self.inputTextField.text] doubleValue];
}

- (IBAction)submitButtonPressed
{
    [self.inputTextField resignFirstResponder];

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *authenticationToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@/datapoints.json", kBaseURL, kAPIPrefix, username, self.goalObject.slug]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"auth_token=%@&value=%@&timestamp=%i", authenticationToken, self.inputTextField.text, (int)[[NSDate date]timeIntervalSince1970]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if ([JSON objectForKey:@"errors"]) {
            [DejalBezelActivityView currentActivityView].activityLabel.text = @"Error";
        }
        else {
            [self loadGraphImage];
            [DejalBezelActivityView currentActivityView].activityLabel.text = @"Saved";
        }
        [DejalBezelActivityView currentActivityView].activityIndicator.hidden = YES;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [DejalBezelActivityView removeViewAnimated:NO];
            [self pollUntilGraphIsNotUpdating];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [DejalBezelActivityView removeViewAnimated:YES];
    }];
    [operation start];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Saving..."];
}

- (void)pollUntilGraphIsNotUpdating
{
    // guilty until proven innocent
    self.graphIsUpdating = YES;
    [DejalBezelActivityView activityViewForView:self.graphButton withLabel:@"Updating Graph..."];
    
    self.graphPoller = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkIfGraphIsUpdating) userInfo:nil repeats:YES];
}

- (void)checkIfGraphIsUpdating
{
    [DejalBezelActivityView activityViewForView:self.graphButton withLabel:@"Updating Graph..."];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *authenticationToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"];
    
    NSURL *goalUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json?auth_token=%@", kBaseURL, kAPIPrefix, username, self.goalObject.slug, authenticationToken]];
    
    NSMutableURLRequest *goalRequest = [NSMutableURLRequest requestWithURL:goalUrl];
    
    AFJSONRequestOperation *goalOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:goalRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.graphIsUpdating = [[JSON objectForKey:@"graph_queued_for_update"] boolValue];
        if (!self.graphIsUpdating) {
            [self.graphPoller invalidate];
            [self loadGraphImage];
            [DejalBezelActivityView removeView];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // nothing...
    }];
    
    [goalOperation start];
}

- (void)updateTimer
{
    self.timerLabel.text = self.goalObject.countdownText;    
}

- (void)startTimer {
    [self updateTimer];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

#pragma mark Keyboard notifications

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    CGPoint origin = self.inputStepper.frame.origin;
    CGFloat height = self.inputStepper.frame.size.height;
    CGFloat buffer = 10.0;
    origin.y -= self.scrollView.contentOffset.y;
    origin.y += height;
    origin.y += buffer;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.inputStepper.frame.origin.y - (aRect.size.height) + height + buffer);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToGraphView"]) {
        GoalGraphViewController *ggvCon = (GoalGraphViewController *)segue.destinationViewController;
        ggvCon.graphImage = self.graphImage;
    }
    else {
        [(AdvancedRoalDialViewController *)segue.destinationViewController setGoalObject: self.goalObject];
        [(AdvancedRoalDialViewController *)segue.destinationViewController setGsvCon: self];
    }
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

- (void)modalDidSaveRoadDial
{
    [self pollUntilGraphIsNotUpdating];
}

- (void)viewDidUnload {
    [self setGraphButton:nil];
    [self setUnitsLabel:nil];
    [self setInstructionLabel:nil];
    [self setInputTextField:nil];
    [self setInputStepper:nil];
    [self setSubmitButton:nil];
    [self setTimerLabel:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

@end
