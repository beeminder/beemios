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
@synthesize editGoalButton = _editGoalButton;
@synthesize addDataButton = _addDataButton;
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
    [GradientViews addGrayButtonGradient:self.editGoalButton];
    [GradientViews addGrayButtonGradient:self.addDataButton];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
    
    if (self.goalObject.gurl) {
        [self.graphButton setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2.5)];
    }
    
    if (self.goalObject.units) {
        self.unitsLabel.text = self.goalObject.units;
    }
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"goal = %@", self.goalObject];
    
    NSArray *datapoints = [Datapoint MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:pred];
    self.inputStepper.value = [[(Datapoint *)[datapoints lastObject] value] doubleValue];

    self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];
    [self registerForKeyboardNotifications];
    [self startTimer];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadGraphImage];
}

- (void)loadGraphImage
{
    if (self.goalObject.gurl) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.goalObject.gurl] options:NSDataReadingUncached error:nil];
        self.graphImage = [[UIImage alloc] initWithData:imageData];
        [self.graphButton setBackgroundImage:self.graphImage forState:UIControlStateNormal];
    }
}

- (void)successfulGoalFetchJSON:(id)responseJSON
{
    for (NSDictionary *datapointDict in [responseJSON objectForKey:@"datapoints"]) {

        NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
        Datapoint *datapoint = [Datapoint MR_findFirstByAttribute:@"serverId" withValue:[datapointDict objectForKey:@"id"]];
        
        if (!datapoint) {
            datapoint = [Datapoint MR_createEntity];
        }
        
        datapoint.value = [datapointDict objectForKey:@"value"];
        datapoint.comment = [datapointDict objectForKey:@"comment"];
        datapoint.timestamp = [datapointDict objectForKey:@"timestamp"];
        datapoint.serverId = [datapointDict objectForKey:@"id"];
        datapoint.goal = self.goalObject;
        [defaultContext MR_save];
    }
    
    NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseJSON];
    
    [mutableResponse removeObjectForKey:@"datapoints"];
    
    [Goal writeToGoalWithDictionary:mutableResponse forUserWithUsername:[ABCurrentUser username]];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"goal = %@", self.goalObject];

    NSArray *datapoints = [Datapoint MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:pred];
    self.inputStepper.value = [[(Datapoint *)[datapoints lastObject] value] doubleValue];
    
    self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];

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
    
    Datapoint *datapoint = [Datapoint MR_createEntity];

    datapoint.value = [NSDecimalNumber decimalNumberWithString:self.inputTextField.text];
    datapoint.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    datapoint.goal = self.goalObject;
    
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@/datapoints.json", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"auth_token=%@&value=%@&timestamp=%i", [ABCurrentUser authenticationToken], self.inputTextField.text, (int)[[NSDate date]timeIntervalSince1970]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if ([JSON objectForKey:@"errors"]) {
            hud.labelText = @"Error";
        }
        else {
            [self loadGraphImage];
            hud.labelText = @"Saved";
        }
        hud.mode = MBProgressHUDModeText;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self pollUntilGraphIsNotUpdating];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    [operation start];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving...";
}

- (void)pollUntilGraphIsNotUpdating
{
    [self.graphPoller invalidate];
    self.graphIsUpdating = YES;
    [self checkIfGraphIsUpdating];
    self.graphPoller = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkIfGraphIsUpdating) userInfo:nil repeats:YES];
}

- (void)checkIfGraphIsUpdating
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.graphButton animated:YES];
    hud.labelText = @"Updating Graph...";
    
    NSURL *goalUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json?auth_token=%@", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug, [ABCurrentUser authenticationToken]]];
    
    NSMutableURLRequest *goalRequest = [NSMutableURLRequest requestWithURL:goalUrl];
    
    AFJSONRequestOperation *goalOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:goalRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulGoalFetchJSON:JSON];
        self.graphIsUpdating = [[JSON objectForKey:@"queued"] boolValue];
        if (!self.graphIsUpdating) {
            [self.graphPoller invalidate];
            [self loadGraphImage];
            [MBProgressHUD hideAllHUDsForView:self.graphButton animated:YES];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // nothing...
    }];
    
    [goalOperation start];
}

- (void)updateTimer
{
    self.timerLabel.text = [self.goalObject losedateTextBrief:NO];
    self.timerLabel.textColor = [self.goalObject losedateColor];
}

- (void)startTimer {
    [self updateTimer];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.graphPoller invalidate];
    }
    [super viewWillDisappear:animated];
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
    CGPoint origin = self.addDataButton.frame.origin;
    CGFloat height = self.addDataButton.frame.size.height;
    CGFloat buffer = 10.0;
    origin.y -= self.scrollView.contentOffset.y;
    origin.y += height;
    origin.y += buffer;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.addDataButton.frame.origin.y - (aRect.size.height) + height + buffer);
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
    [self setEditGoalButton:nil];
    [self setAddDataButton:nil];
    [super viewDidUnload];
}

@end
