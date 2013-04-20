//
//  GoalSummaryViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalSummaryViewController.h"
#import "AdvancedRoadDialViewController.h"
#import "ContractViewController.h"

@interface GoalSummaryViewController ()

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

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.clipsToBounds = YES;
    self.scrollView.contentSize = self.graphImageView.image.size;
    self.scrollView.delegate = self;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.inputTextField.leftView = paddingView;
    self.inputTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.inputTextField.backgroundColor = [BeeminderAppDelegate cloudsColor];
    self.inputTextField.font = [UIFont fontWithName:@"Lato" size:16.0f];
    self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato" size:16.0f];
    self.timerLabel.font = [UIFont fontWithName:@"Lato-Bold" size:20.0f];
    
    // set the tag for the image view
    [self.graphImageView setTag:ZOOM_VIEW_TAG];
    
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [self.graphImageView addGestureRecognizer:singleTap];
    [self.graphImageView addGestureRecognizer:doubleTap];
    [self.graphImageView addGestureRecognizer:twoFingerTap];

    [self loadGraphImageIgnoreCache:YES];
    [self loadGraphImageThumbIgnoreCache:YES];

    self.editGoalButton = [BeeminderAppDelegate standardGrayButtonWith:self.editGoalButton];
    self.editGoalButton.titleLabel.font = [UIFont fontWithName:@"Lato" size:16.0f];
    self.addDataButton = [BeeminderAppDelegate standardGrayButtonWith:self.addDataButton];
//    self.rerailButton = [BeeminderAppDelegate standardGrayButtonWith:self.rerailButton];
    if (self.goalObject.units) {
        self.unitsLabel.text = self.goalObject.units;
    }
    [self setInitialDatapoint];
    [self setDatapointsText];
    [self adjustForFrozen];
    [self startTimer];
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshGoalData)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
    
    if (self.needsFreshData) {
        [self refreshGoalData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)adjustForFrozen
{
    if ([self.goalObject canAcceptData]) {
        self.editGoalButton.hidden = NO;
        self.inputTextField.hidden = NO;
        self.valueStepper.hidden = NO;
        self.dateStepper.hidden = NO;
        self.addDataButton.hidden = NO;
        self.dateStepperLabel.hidden = NO;
        self.valueStepperLabel.hidden = NO;
        self.rerailButton.hidden = YES;
    }
    else {
        self.editGoalButton.hidden = YES;
        self.inputTextField.hidden = YES;
        self.valueStepper.hidden = YES;
        self.dateStepper.hidden = YES;
        self.addDataButton.hidden = YES;
        self.dateStepperLabel.hidden = YES;
        self.valueStepperLabel.hidden = YES;
    }
}

- (void)replaceRefreshButton
{
    [self.activityIndicator stopAnimating];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshGoalData)];
    self.navigationItem.rightBarButtonItem = self.refreshButton;
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

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json?access_token=%@&datapoints_count=3", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug, [ABCurrentUser accessToken]]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self replaceRefreshButton];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary *modGoalDict = [Goal processGoalDictFromServer:JSON];
        
        [Goal writeToGoalWithDictionary:modGoalDict forUserWithUsername:[ABCurrentUser username]];
        
        [self loadGraphImageIgnoreCache:YES];
        [self loadGraphImageThumbIgnoreCache:YES];
        if ([[JSON objectForKey:@"queued"] boolValue]) {
            [self pollUntilGraphIsNotUpdating];
        }
        [self adjustForFrozen];
        [self startTimer];
        [BeeminderAppDelegate updateApplicationIconBadgeCount];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self replaceRefreshButton];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    
    [operation start];
}

- (void)setInitialDatapoint
{
    self.datapointDate = [NSDate date];
    
    Datapoint *datapoint = [[self sortedDatapoints] lastObject];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];
    
    NSDecimalNumber *datapointValue;
    if (datapoint) {
        datapointValue = datapoint.value;
    }
    else {
        datapointValue = [NSDecimalNumber decimalNumberWithString:@"0"];
    }

    self.inputTextField.text = [NSString stringWithFormat:@"%d %@", [dateComponents day], datapointValue];
    
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
            self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato" size:16.0f];
            self.lastDatapointLabel.text = kWinnerText;
        }
        else if ([self.goalObject.lost boolValue]) {
            self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato" size:16.0f];
            self.lastDatapointLabel.text = kDerailedText;
        }
    }
    else {
        self.lastDatapointLabel.font = [UIFont fontWithName:@"Lato" size:16.0f];
        NSUInteger datapointCount = [self.goalObject.datapoints count];
        NSArray *showDatapoints;
        if (datapointCount < 4) {
            showDatapoints = [self sortedDatapoints];
        }
        else {
            showDatapoints = [[self sortedDatapoints] objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(datapointCount - 3, 3)]];
        }
        
        NSString *lastDatapointsText = @"";
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d"];
        
        for (Datapoint *datapoint in showDatapoints) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[datapoint.timestamp doubleValue]];
            
            NSString *day = [formatter stringFromDate:date];
            NSString *comment = [NSString stringWithFormat:@"%@ %@", day, datapoint.value];
            
            if (datapoint.comment.length > 30) {
                comment = [comment stringByAppendingFormat:@" \"%@...\"\n", [datapoint.comment substringToIndex:30]];
            }
            else if (datapoint.comment.length > 0) {
                comment = [comment stringByAppendingFormat:@" \"%@\"\n", datapoint.comment];
            }
            else {
                comment = [comment stringByAppendingString:@"\n"];
            }
            
            lastDatapointsText = [lastDatapointsText stringByAppendingString:comment];
        }
        self.lastDatapointLabel.text = lastDatapointsText;
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
    if (ignoreCache || !self.goalObject.graph_image_thumb) {
        [self.goalObject updateGraphImageThumbWithCompletionBlock:^(void){
            [self loadGraphImageThumbIgnoreCache:NO];
        }];
    }
}

- (void)successfulGoalFetchJSON:(id)responseJSON
{ 
    NSMutableDictionary *mutableResponse = [NSMutableDictionary dictionaryWithDictionary:responseJSON];
    
    [mutableResponse removeObjectForKey:@"datapoints"];
    
    [Goal writeToGoalWithDictionary:mutableResponse forUserWithUsername:[ABCurrentUser username]];

    [self startTimer];
}

- (void)failedDatapointsFetch
{
    
}

- (void)updateInputTextFieldText
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    NSString *day = [dateFormatter stringFromDate:self.datapointDate];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    
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
    
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@/datapoints.json", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"access_token=%@&urtext=%@", [ABCurrentUser accessToken], self.inputTextField.text];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if ([JSON objectForKey:@"errors"]) {
            hud.labelText = @"Error";
        }
        else {
            hud.labelText = @"Saved";
            [self pollUntilGraphIsNotUpdating];
            [self refreshGoalData];
            Datapoint *datapoint = [Datapoint MR_createEntity];
            datapoint.goal = self.goalObject;
            datapoint.serverId = [JSON objectForKey:@"id"];
            datapoint.value = [JSON objectForKey:@"value"];
            datapoint.timestamp = [JSON objectForKey:@"timestamp"];
            datapoint.comment = [JSON objectForKey:@"comment"];
            datapoint.updatedAt = [JSON objectForKey:@"updated_at"];
            [[NSManagedObjectContext MR_defaultContext] MR_save];
            [self setDatapointsText];
            [self setInitialDatapoint];
        }
        hud.mode = MBProgressHUDModeText;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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

    NSURL *goalUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json?access_token=%@", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug, [ABCurrentUser accessToken]]];
    
    NSMutableURLRequest *goalRequest = [NSMutableURLRequest requestWithURL:goalUrl];
    
    AFJSONRequestOperation *goalOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:goalRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulGoalFetchJSON:JSON];
        self.graphIsUpdating = [[JSON objectForKey:@"queued"] boolValue];
        if (!self.graphIsUpdating) {
            [self.graphPoller invalidate];
            [self loadGraphImageIgnoreCache:YES];
            [MBProgressHUD hideAllHUDsForView:self.graphImageView animated:YES];
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

- (IBAction)editGoalButtonPressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    AdvancedRoalDialViewController *advCon = [storyboard instantiateViewControllerWithIdentifier:@"advancedRoadDialViewController"];
    advCon.goalObject = self.goalObject;
    [self presentViewController:advCon animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [(AdvancedRoalDialViewController *)segue.destinationViewController setGoalObject: self.goalObject];
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
    float newScale = [self.scrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.graphScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [self.scrollView zoomScale] / ZOOM_STEP;
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
    [self setEditGoalButton:nil];
    [self setAddDataButton:nil];
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
