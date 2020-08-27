//
//  GoalSummaryViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalSummaryViewController.h"
#import "constants.h"
#define kDefaultStepperWidth 94
#define kLeftMargin 20

@interface GoalSummaryViewController ()

@property int datapointsCount;

@end

@implementation GoalSummaryViewController

#define ZOOM_STEP 2.0
#define ZOOM_VIEW_TAG 100

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
    
    if (self.view.frame.size.height > 500) {
        self.datapointsCount = 5;
        self.deltasLabel.textAlignment = NSTextAlignmentCenter;
    }
    else {
        self.datapointsCount = 3;
        self.deltasLabel.hidden = YES;
    }
    
    self.scrollView.clipsToBounds = YES;	
	self.scrollView.contentSize = self.graphImageView.image.size;
    self.scrollView.delegate = self;
    
    self.timerLabel.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
	
	self.dateStepperLabel.textAlignment = NSTextAlignmentCenter;
    self.dateStepperLabel.text = @"Date";
    self.dateStepperLabel.font = [UIFont fontWithName:@"Lato" size:15.0f];
    self.valueStepperLabel.textAlignment = NSTextAlignmentCenter;
    self.valueStepperLabel.text = @"Datapoint";
    self.valueStepperLabel.font = [UIFont fontWithName:@"Lato" size:15.0f];
	
	self.dateStepper.tintColor = [UIColor blackColor];
    [self.dateStepper addTarget:self action:@selector(dateStepperValueChanged) forControlEvents:UIControlEventValueChanged];
    self.dateStepper.maximumValue = 1;
    self.dateStepper.minimumValue = -31;

	self.valueStepper.tintColor = [UIColor blackColor];
    [self.valueStepper addTarget:self action:@selector(valueStepperValueChanged) forControlEvents:UIControlEventValueChanged];
    self.valueStepper.maximumValue = 1000000;
    self.valueStepper.minimumValue = -1000000;

	self.inputTextField.leftViewMode = UITextFieldViewModeAlways;
    self.inputTextField.backgroundColor = [BeeminderAppDelegate cloudsColor];
    self.inputTextField.font = [UIFont fontWithName:@"Lato" size:16.0f];
    self.inputTextField.borderStyle = UITextBorderStyleNone;
    self.inputTextField.returnKeyType = UIReturnKeyDone;
    [self.inputTextField addTarget:self action:@selector(inputTextFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
    self.inputTextField.delegate = self;

	[self.graphImageView setTag:ZOOM_VIEW_TAG];
    
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    // add gesture recognizer to go back
    UISwipeGestureRecognizer *leftRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:leftRecognizer];
    
    [self.graphImageView addGestureRecognizer:singleTap];
    [self.graphImageView addGestureRecognizer:doubleTap];
    [self.graphImageView addGestureRecognizer:twoFingerTap];

    [self loadGraphImageIgnoreCache:YES];

    self.submitButton = [BeeminderAppDelegate standardGrayButtonWith:self.submitButton];
	[self.submitButton setTitle:@"Enter" forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(submitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	
	self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato" size:16.0f];
    self.lastDatapointLabel.numberOfLines = self.datapointsCount;
    
    if (self.goalObject.units) {
        self.unitsLabel.text = self.goalObject.units;
    }
    [self setInitialDatapoint];
    [self setDatapointsText];
    [self adjustForFrozen];
    [self startTimer];
    
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flat-refresh"]];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshGoalData)];
    [view addGestureRecognizer:recognizer];
    self.refreshButton = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.refreshButton.target = self;
    self.refreshButton.action = @selector(refreshGoalData);
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25,0, 227, 32)];
    self.titleLabel.text = self.title;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = self.titleLabel;
    
    [self refreshGoalData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submitButtonPressed];
    return YES;
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    [self back];
}

- (void)adjustForFrozen
{
    if ([self.goalObject canAcceptData]) {
        self.inputTextField.hidden = NO;
        self.valueStepper.hidden = NO;
        self.dateStepper.hidden = NO;
        self.submitButton.hidden = NO;
        self.dateStepperLabel.hidden = NO;
        self.valueStepperLabel.hidden = NO;
        self.rerailButton.hidden = YES;
    }
    else {
        self.inputTextField.hidden = YES;
        self.valueStepper.hidden = YES;
        self.dateStepper.hidden = YES;
        self.submitButton.hidden = YES;
        self.dateStepperLabel.hidden = YES;
        self.valueStepperLabel.hidden = YES;
    }
}

- (void)replaceRefreshButton
{
    [self.activityIndicator stopAnimating];
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flat-refresh"]];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshGoalData)];
    [view addGestureRecognizer:recognizer];
    self.refreshButton = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.refreshButton.target = self;
    self.refreshButton.action = @selector(refreshGoalData);
    self.navigationItem.rightBarButtonItem = self.refreshButton;
}

- (void)updateDeltaLabel:(NSString *)deltaText yaw:(NSNumber *)yaw
{
    [self.deltasLabel setAttributedText:[BeeminderAppDelegate attributedDeltasString:deltaText yaw:yaw]];
}

- (void)refreshGoalData
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator startAnimating];
    self.refreshButton = [[self.navigationItem rightBarButtonItem] initWithCustomView:self.activityIndicator];
    [MBProgressHUD hideAllHUDsForView:self.graphImageView animated:NO];
    if (![MBProgressHUD HUDForView:self.view]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[ABCurrentUser accessToken], @"access_token", [NSNumber numberWithInt:self.datapointsCount], @"datapoints_count", nil];
    
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager GET:[NSString stringWithFormat:@"/api/v1/users/me/goals/%@.json", self.goalObject.slug] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (Datapoint *d in self.goalObject.datapoints) {
            [d MR_deleteEntity];
        }
        NSString *deltaText = [responseObject objectForKey:@"delta_text"];
        [self updateDeltaLabel:deltaText yaw:[responseObject objectForKey:@"yaw"]];

        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [self replaceRefreshButton];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary *modGoalDict = [Goal processGoalDictFromServer:responseObject];
        
        [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];
        
        [self loadGraphImageIgnoreCache:YES];
        [self loadGraphImageThumbIgnoreCache:YES];
        if ([[responseObject objectForKey:@"queued"] boolValue]) {
            [self pollUntilGraphIsNotUpdating];
        }
        [self adjustForFrozen];
        [self startTimer];
        [BeeminderAppDelegate updateApplicationIconBadgeCount];
        [self setDatapointsText];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self replaceRefreshButton];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

- (void)back {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setInitialDatapoint
{
    self.datapointDate = [NSDate date];
    
    Datapoint *datapoint = [[self sortedDatapoints] lastObject];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterDecimalStyle];
    formatter.usesSignificantDigits = YES;
    
    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];
    
    NSDecimalNumber *datapointValue;
    if (datapoint) {
        datapointValue = datapoint.value;
    }
    else {
        datapointValue = [NSDecimalNumber decimalNumberWithString:@"0"];
    }

    self.inputTextField.text = [NSString stringWithFormat:@"%ld %@", (long)[dateComponents day], [formatter stringFromNumber:datapointValue]];
    self.dateStepper.value = 0;
    self.valueStepper.value = [datapoint.value doubleValue];

}

- (NSArray *)sortedDatapoints
{
    return [[self.goalObject.datapoints allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Datapoint *d1 = (Datapoint *)obj1;
        Datapoint *d2 = (Datapoint *)obj2;
        if ([d1.updatedAt doubleValue] < [d2.updatedAt doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else {
            return (NSComparisonResult)NSOrderedDescending;
        }
    }];
}

-(void)setDatapointsText
{
    if ([self.goalObject.frozen boolValue]) {
        if ([self.goalObject.won boolValue]) {
            self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16.0f];
            self.lastDatapointLabel.text = kWinnerText;
        }
        else if ([self.goalObject.lost boolValue]) {
            self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16.0f];
            self.lastDatapointLabel.text = kDerailedText;
        }
    }
    else {
        self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato" size:15.0f];
        NSString *lastDatapointsText = @"";
        
        for (Datapoint *datapoint in [self sortedDatapoints]) {
            NSString *strippedCanonical = datapoint.canonical;
            if ([[datapoint.canonical substringToIndex:1] isEqualToString:@"0"]) {
                strippedCanonical = [datapoint.canonical substringFromIndex:1];
            }
            if (strippedCanonical.length > 37) {
                strippedCanonical = [NSString stringWithFormat:@"%@...", [strippedCanonical substringToIndex:37]];
            }
            lastDatapointsText = [lastDatapointsText stringByAppendingString:[NSString stringWithFormat:@"%@\n", strippedCanonical]];
        }
        self.lastDatapointLabel.text = [lastDatapointsText substringToIndex:lastDatapointsText.length - 1];
    }
}

- (void)loadGraphImage
{
    [self loadGraphImageIgnoreCache:NO];
}

- (void)loadGraphImageIgnoreCache:(BOOL)ignoreCache
{
    if (ignoreCache || !self.goalObject.graph_image) {
        [self.goalObject updateGraphImageWithCompletionBlock:^(void){
            [self loadGraphImageIgnoreCache:NO];
        }];
    }
    else {
        self.graphImageView.image = self.goalObject.graph_image;
    }
}

- (void)loadGraphImageThumbIgnoreCache:(BOOL)ignoreCache
{
    [self.goalObject updateGraphImageThumb];
}

- (void)successfulGoalFetchJSON:(id)responseJSON
{ 
    NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseJSON];
    
    [mutableResponse removeObjectForKey:@"datapoints"];
    
    [Goal writeToGoalWithDictionary:mutableResponse forUserWithUsername:[ABCurrentUser username]];

    [self startTimer];
}

- (void)updateInputTextFieldText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    NSString *day = [dateFormatter stringFromDate:self.datapointDate];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@""];
    
    NSString *inputText = [NSString stringWithFormat:@"%@ ", day];
    
    if (self.datapointDecimalValue) {
        NSString *decimalString = [numberFormatter stringFromNumber:self.datapointDecimalValue];
        if ([self.datapointDecimalValue doubleValue] < 0) {
            decimalString = [decimalString substringFromIndex:2];
            if (self.valueStepper.value == 0) {
                inputText = [inputText stringByAppendingFormat:@"-0%@", decimalString];
            }
            else {
                inputText = [inputText stringByAppendingFormat:@"%d%@", (int)self.valueStepper.value, decimalString];
            }
        }
        else {
            decimalString = [decimalString substringFromIndex:1];
            inputText = [inputText stringByAppendingFormat:@"%d%@", (int)self.valueStepper.value, decimalString];
        }

    }
    else {
        inputText = [inputText stringByAppendingString:[numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.valueStepper.value]]];
    }

    if ([self.datapointComment length] > 0) {
        inputText = [inputText stringByAppendingFormat:@" \"%@\"", self.datapointComment];
    }
    
    self.inputTextField.text = inputText;
}

- (IBAction)dateStepperValueChanged
{
    self.datapointDate = [NSDate dateWithTimeIntervalSinceNow:self.dateStepper.value * 24 * 3600];
    [self updateInputTextFieldText];
}

- (IBAction)valueStepperValueChanged
{
    if (ABS(self.valueStepper.value) == 1) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\-" options:0 error:nil];
        NSUInteger matchCount = [regex numberOfMatchesInString:self.inputTextField.text options:0 range:NSMakeRange(0, self.inputTextField.text.length)];
        if (self.datapointDecimalValue &&
            ((matchCount == 0 && self.valueStepper.value == -1) ||
            (matchCount == 1 && self.valueStepper.value == 1))) {
            self.valueStepper.value = 0;
            self.datapointDecimalValue = [NSNumber numberWithDouble:-1*[self.datapointDecimalValue doubleValue]];
        }
    }
    [self updateInputTextFieldText];
}

- (NSDictionary *)parseInputTextField
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d{1,2})\\s([\\d\\.\\-]+)(\\s)?(\"([^\"]*)\")?$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *string = self.inputTextField.text;
    
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];

    if (result) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *day = [formatter numberFromString:[string substringWithRange:[result rangeAtIndex:1]]];
        NSString *fullVal = [string substringWithRange:[result rangeAtIndex:2]];
        NSRegularExpression *decimalRegex = [NSRegularExpression regularExpressionWithPattern:@"\\d?(\\.\\d+)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *decimalResult = [decimalRegex firstMatchInString:fullVal options:0 range:NSMakeRange(0, [fullVal length])];
        
        NSNumber *intVal = [NSNumber numberWithInt:[[formatter numberFromString:fullVal] integerValue]];
        NSNumber *decimalVal = [formatter numberFromString:[fullVal substringWithRange:[decimalResult rangeAtIndex:1]]];
        
        
        NSString *comment = @"";
        BOOL aboutToComment = NO;
        if ([result rangeAtIndex:5].length > 0) {
            comment = [string substringWithRange:[result rangeAtIndex:5]];
        }
        else if ([result rangeAtIndex:3].length > 0 && [result rangeAtIndex:4].length == 0) {
            aboutToComment = YES;
        }


        return [NSDictionary dictionaryWithObjectsAndKeys:day, @"day", intVal, @"intVal", comment, @"comment", [NSNumber numberWithBool:aboutToComment], @"aboutToComment", decimalVal, @"decimalVal", nil];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:nil, @"day", nil, @"val", nil, "@comment", nil];
}

- (IBAction)inputTextFieldEditingChanged
{
    [self saveDatapointLocally];
    if ([[self.inputTextField.text componentsSeparatedByString:@"\""] count] == 2 && [[self.inputTextField.text substringFromIndex:self.inputTextField.text.length - 1] isEqualToString:@"\""]) {
        self.inputTextField.text = [self.inputTextField.text substringToIndex:self.inputTextField.text.length - 1];
    }
}

- (void)saveDatapointLocally
{
    NSDictionary *dict = [self parseInputTextField];
    if (![dict objectForKey:@"day"]) {
        return;
    }
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];

    NSInteger monthOffset = ([[dict objectForKey:@"day"] integerValue] > [dateComponents day]) ? -1 : 0;

    [dateComponents setMonth:[dateComponents month] + monthOffset];
    [dateComponents setDay:[[dict objectForKey:@"day"] integerValue]];
    [dateComponents setTimeZone:[NSTimeZone localTimeZone]];

    NSDate *date = [gregorian dateFromComponents:dateComponents];
    
    self.datapointDate = date;
    self.dateStepper.value = (int)[date timeIntervalSinceNow]/(24*3600);

    self.valueStepper.value = [[dict objectForKey:@"intVal"] doubleValue];
    self.datapointDecimalValue = [dict objectForKey:@"decimalVal"];
    
    self.datapointComment = [dict objectForKey:@"comment"];
    if ([[dict objectForKey:@"aboutToComment"] boolValue]) {
        self.inputTextField.text = [self.inputTextField.text stringByAppendingString:@"\"\""];

        UITextPosition *endOfDoc = self.inputTextField.endOfDocument;
        UITextPosition *start = [self.inputTextField positionFromPosition:endOfDoc offset:-1];
        UITextPosition *end = [self.inputTextField positionFromPosition:endOfDoc offset:-1];
        
        [self.inputTextField setSelectedTextRange:[self.inputTextField textRangeFromPosition: start toPosition:end]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // canceled
    }
    else {
        [self submitDatapoint];
    }
}

- (IBAction)submitButtonPressed
{
    [self.inputTextField resignFirstResponder];
    
    if ([self.goalObject isDerailed]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Frozen graph!" message:@"This goal is currently derailed. Adding data won't update the graph. \n\nEmail support@beeminder.com to unfreeze!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add data anyway", nil];
        [alert show];
    }
    else {
        [self submitDatapoint];
    }
}

- (void)submitDatapoint
{
    [self saveDatapointLocally];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[ABCurrentUser accessToken], @"access_token", self.inputTextField.text, @"urtext", nil];
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager POST:[NSString stringWithFormat:@"/api/v1/users/me/goals/%@/datapoints.json", self.goalObject.slug] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if ([responseObject objectForKey:@"errors"]) {
            hud.labelText = @"Error";
        }
        else {
            hud.labelText = @"Saved";
            [self refreshGoalData];
            Datapoint *datapoint = [Datapoint MR_createEntity];
            datapoint.goal = self.goalObject;
            datapoint.serverId = [responseObject objectForKey:@"id"];
            datapoint.value = [responseObject objectForKey:@"value"];
            datapoint.timestamp = [responseObject objectForKey:@"timestamp"];
            datapoint.comment = [responseObject objectForKey:@"comment"];
            datapoint.updatedAt = [responseObject objectForKey:@"updated_at"];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            [self setDatapointsText];
            [self setInitialDatapoint];
        }
        hud.mode = MBProgressHUDModeText;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving...";
}

- (void)pollUntilGraphIsNotUpdating
{
    [self.graphPoller invalidate];
    self.graphIsUpdating = YES;
    [self checkIfGraphIsUpdating];
    if (![MBProgressHUD HUDForView:self.graphImageView]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.graphImageView animated:YES];
        hud.labelText = @"Updating Graph...";
    }
    self.graphPoller = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkIfGraphIsUpdating) userInfo:nil repeats:YES];
}

- (void)checkIfGraphIsUpdating
{
    if (![MBProgressHUD HUDForView:self.graphImageView]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.graphImageView animated:YES];
        hud.labelText = @"Updating Graph...";
    }

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[ABCurrentUser accessToken], @"access_token", nil];
    
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager GET:[NSString stringWithFormat:@"/%@/users/me/goals/%@.json", kAPIPrefix, self.goalObject.slug] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self successfulGoalFetchJSON:responseObject];
        self.graphIsUpdating = [[responseObject objectForKey:@"queued"] boolValue];
        if (!self.graphIsUpdating) {
            NSString *deltaText = [responseObject objectForKey:@"delta_text"];
            [self updateDeltaLabel:deltaText yaw:[responseObject objectForKey:@"yaw"]];
            [self.graphPoller invalidate];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goalUpdated" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.goalObject, @"goal", nil]];
            [self loadGraphImageIgnoreCache:YES];
            [MBProgressHUD hideAllHUDsForView:self.graphImageView animated:YES];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //baz
    }];
}

- (void)updateTimer
{
    self.timerLabel.text = [self.goalObject losedateTextBrief:NO];
    self.timerLabel.textColor = [self.goalObject losedateColor];
}

- (void)startTimer {
    [self.countdownTimer invalidate];
    [self updateTimer];
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        [self.graphPoller invalidate];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphImageView;
}

#pragma mark tap gesture recognizer methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap does nothing for now
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    float newScale = [self.graphScrollView zoomScale] * ZOOM_STEP;
    if (newScale > self.graphScrollView.maximumZoomScale) newScale = 1;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.graphScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [self.scrollView zoomScale] / ZOOM_STEP;
    if (newScale < self.graphScrollView.minimumZoomScale) return;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.graphScrollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.graphScrollView frame].size.height / scale;
    zoomRect.size.width  = [self.graphScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)viewDidUnload {
    [self setUnitsLabel:nil];
    [self setInstructionLabel:nil];
    [self setInputTextField:nil];
    [self setSubmitButton:nil];
    [self setTimerLabel:nil];
    [self setScrollView:nil];
    [self setLastDatapointLabel:nil];
    [self setDateStepper:nil];
    [self setValueStepper:nil];
    [self setValueStepperLabel:nil];
    [self setDateStepperLabel:nil];
    [self setRerailButton:nil];
    [self setGraphScrollView:nil];
    [self setGraphImageView:nil];
    [super viewDidUnload];
}

@end
