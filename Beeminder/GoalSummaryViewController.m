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
    self.inputTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.editGoalButton = [BeeminderAppDelegate standardGrayButtonWith:self.editGoalButton];
    self.addDataButton = [BeeminderAppDelegate standardGrayButtonWith:self.addDataButton];
    
    if (self.goalObject.units) {
        self.unitsLabel.text = self.goalObject.units;
    }
    
    self.inputStepper.value = [[(Datapoint *)[[self.goalObject.datapoints allObjects] lastObject] value] doubleValue];


    [self setDatapointsText];

    self.inputTextField.text = [NSString stringWithFormat:@"%i", (int)self.inputStepper.value];
    [self startTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadGraphImage];
}

//- (void)loadDatapoints
//{
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"goal = %@", self.goalObject];
//    
//    self.datapoints = [Datapoint MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:pred inContext:[NSManagedObjectContext MR_defaultContext]];
//}

-(void)setDatapointsText
{
    NSUInteger datapointCount = [self.goalObject.datapoints count];
    NSArray *showDatapoints;
    if (datapointCount < 4) {
        showDatapoints = [self.goalObject.datapoints allObjects];
    }
    else {
        showDatapoints = [[self.goalObject.datapoints allObjects] objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(datapointCount - 3, 3)]];
    }
    
    NSString *lastDatapointsText = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    
    for (Datapoint *datapoint in showDatapoints) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[datapoint.timestamp doubleValue]];
        
        
        NSString *day = [formatter stringFromDate:date];
        NSString *comment = [NSString stringWithFormat:@"%@ %@", day, datapoint.value];
        
        if (datapoint.comment) {
            comment = [comment stringByAppendingFormat:@" %@\n", datapoint.comment];
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
    for (NSDictionary *datapointDict in [responseJSON objectForKey:@"datapoints"]) {

        NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
        Datapoint *datapoint = [Datapoint MR_findFirstByAttribute:@"serverId" withValue:[datapointDict objectForKey:@"id"] inContext:[NSManagedObjectContext MR_defaultContext]];
        
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

    NSArray *datapoints = [Datapoint MR_findAllSortedBy:@"timestamp" ascending:YES withPredicate:pred inContext:[NSManagedObjectContext MR_defaultContext]];
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
    [self.commentTextField resignFirstResponder];
    Datapoint *datapoint = [Datapoint MR_createEntity];

    datapoint.value = [NSDecimalNumber decimalNumberWithString:self.inputTextField.text];
    datapoint.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    datapoint.comment = self.commentTextField.text;
    datapoint.goal = self.goalObject;
    
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/users/%@/goals/%@/datapoints.json", kBaseURL, kAPIPrefix, [ABCurrentUser username], self.goalObject.slug]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"access_token=%@&value=%@&timestamp=%i&comment=%@", [ABCurrentUser accessToken], self.inputTextField.text, (int)[[NSDate date]timeIntervalSince1970], AFURLEncodedStringFromStringWithEncoding(self.commentTextField.text, NSUTF8StringEncoding)];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
        if ([JSON objectForKey:@"errors"]) {
            hud.labelText = @"Error";
        }
        else {
            [self loadGraphImageIgnoreCache:YES];
            hud.labelText = @"Saved";
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
    NSLog(@"foo");
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
    [self setInputStepper:nil];
    [self setSubmitButton:nil];
    [self setTimerLabel:nil];
    [self setScrollView:nil];
    [self setEditGoalButton:nil];
    [self setAddDataButton:nil];
    [self setCommentTextField:nil];
    [self setLastDatapointLabel:nil];
    [super viewDidUnload];
}

@end
