//
//  GoalSummaryViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalSummaryViewController.h"
#import "GoalGraphViewController.h"
#import "AdvancedRoadDialViewController.h"

@interface GoalSummaryViewController ()

@end

@implementation GoalSummaryViewController

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

    [self loadGraphImageIgnoreCache:YES];
    [self loadGraphImageThumbIgnoreCache:YES];

    self.editGoalButton = [BeeminderAppDelegate standardGrayButtonWith:self.editGoalButton];
    self.addDataButton = [BeeminderAppDelegate standardGrayButtonWith:self.addDataButton];
    
    if (self.goalObject.units) {
        self.unitsLabel.text = self.goalObject.units;
    }

    [self setDatapointsText];

    [self setInitialDatapoint];

    [self startTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadGraphImage];
}

- (void)setInitialDatapoint
{
    self.datapointDate = [NSDate date];
    
    Datapoint *datapoint = [[self sortedDatapoints] lastObject];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:[NSDate date]];

    self.inputTextField.text = [NSString stringWithFormat:@"%d %@", [dateComponents day], datapoint.value];
    
    self.valueStepper.value = [datapoint.value doubleValue];

}

- (NSArray *)sortedDatapoints
{
    return [[self.goalObject.datapoints allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Datapoint *d1 = (Datapoint *)obj1;
        Datapoint *d2 = (Datapoint *)obj2;
        if ([d1.timestamp doubleValue] < [d2.timestamp doubleValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        else {
            return (NSComparisonResult)NSOrderedDescending;
        }
    }];
}

-(void)setDatapointsText
{
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
        
        if (datapoint.comment.length > 0) {
            comment = [comment stringByAppendingFormat:@" \"%@\"\n", datapoint.comment];
        }
        else {
            comment = [comment stringByAppendingString:@"\n"];
        }
        
        lastDatapointsText = [lastDatapointsText stringByAppendingString:comment];
    }
    self.lastDatapointLabel.text = lastDatapointsText;
}

- (void)loadGraphImage
{
    [self loadGraphImageIgnoreCache:NO];
}

- (void)loadGraphImageIgnoreCache:(BOOL)ignoreCache
{
    if (ignoreCache || !self.goalObject.graph_image) {
        [MBProgressHUD showHUDAddedTo:self.graphButton animated:YES];
        [self.goalObject updateGraphImageWithCompletionBlock:^(void){
            [MBProgressHUD hideAllHUDsForView:self.graphButton animated:YES];
            [self loadGraphImageIgnoreCache:NO];
        }];
    }
    else {
        [self.graphButton setBackgroundImage:self.goalObject.graph_image forState:UIControlStateNormal];
        if (!self.graphPoller || ![self.graphPoller isValid]) {
            [MBProgressHUD hideAllHUDsForView:self.graphButton animated:YES];
        }
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
    
    NSString *inputText = [NSString stringWithFormat:@"%@ %@", day, [numberFormatter stringFromNumber:[NSNumber numberWithDouble:self.valueStepper.value]]];

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
        NSNumber *val = [formatter numberFromString:[string substringWithRange:[result rangeAtIndex:2]]];
        NSString *comment = @"";
        BOOL aboutToComment = NO;
        if ([result rangeAtIndex:5].length > 0) {
            comment = [string substringWithRange:[result rangeAtIndex:5]];
        }
        else if ([result rangeAtIndex:3].length > 0 && [result rangeAtIndex:4].length == 0) {
            aboutToComment = YES;
        }


        return [NSDictionary dictionaryWithObjectsAndKeys:day, @"day", val, @"val", comment, @"comment", [NSNumber numberWithBool:aboutToComment], @"aboutToComment", nil];
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

    self.valueStepper.value = [[dict objectForKey:@"val"] doubleValue];
    
    self.datapointComment = [dict objectForKey:@"comment"];
    if ([[dict objectForKey:@"aboutToComment"] boolValue]) {
        self.inputTextField.text = [self.inputTextField.text stringByAppendingString:@"\"\""];

        UITextPosition *endOfDoc = self.inputTextField.endOfDocument;
        UITextPosition *start = [self.inputTextField positionFromPosition:endOfDoc offset:-1];
        UITextPosition *end = [self.inputTextField positionFromPosition:endOfDoc offset:-1];
        
        [self.inputTextField setSelectedTextRange:[self.inputTextField textRangeFromPosition: start toPosition:end]];
    }
}

- (IBAction)submitButtonPressed
{
    [self.inputTextField resignFirstResponder];

    [self saveDatapointLocally];
    
    Datapoint *datapoint = [Datapoint MR_createEntity];
    
    datapoint.value = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:self.valueStepper.value] decimalValue]];
    if (ABS([self.datapointDate timeIntervalSinceNow]) < 24*3600) {
        datapoint.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    }
    else {
        datapoint.timestamp = [NSNumber numberWithDouble:[self.datapointDate timeIntervalSince1970]];
    }

    datapoint.comment = self.datapointComment;

    datapoint.goal = self.goalObject;
    
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@/datapoints.json", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"access_token=%@&value=%@&timestamp=%@&comment=%@", [ABCurrentUser accessToken], datapoint.value, datapoint.timestamp, AFURLEncodedStringFromStringWithEncoding(self.datapointComment, NSUTF8StringEncoding)];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if ([JSON objectForKey:@"errors"]) {
            hud.labelText = @"Error";
        }
        else {
            NSLog(@"%@", JSON);
            [self loadGraphImageIgnoreCache:YES];
            hud.labelText = @"Saved";
            datapoint.serverId = [JSON objectForKey:@"id"];
            NSLog(@"%@", datapoint.serverId);
            [[NSManagedObjectContext MR_defaultContext] MR_save];
        }
        hud.mode = MBProgressHUDModeText;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self setDatapointsText];
            [self pollUntilGraphIsNotUpdating];
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [datapoint MR_deleteEntity];
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
    
    NSURL *goalUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@.json?access_token=%@", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug, [ABCurrentUser accessToken]]];
    
    NSMutableURLRequest *goalRequest = [NSMutableURLRequest requestWithURL:goalUrl];
    
    AFJSONRequestOperation *goalOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:goalRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self successfulGoalFetchJSON:JSON];
        self.graphIsUpdating = [[JSON objectForKey:@"queued"] boolValue];
        if (!self.graphIsUpdating) {
            [self.graphPoller invalidate];
            [self loadGraphImageIgnoreCache:YES];
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

- (IBAction)editGoalButtonPressed
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    AdvancedRoalDialViewController *advCon = [storyboard instantiateViewControllerWithIdentifier:@"advancedRoadDialViewController"];
    advCon.goalObject = self.goalObject;
    [self presentViewController:advCon animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToGraphView"]) {
        GoalGraphViewController *ggvCon = (GoalGraphViewController *)segue.destinationViewController;
        ggvCon.graphImage = self.goalObject.graph_image;
    }
    else {
        [(AdvancedRoalDialViewController *)segue.destinationViewController setGoalObject: self.goalObject];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGraphButton:nil];
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
    [super viewDidUnload];
}

@end
