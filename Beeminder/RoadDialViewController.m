//
//  RoadDialViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "RoadDialViewController.h"

@interface RoadDialViewController ()

@property (nonatomic, strong) NSArray *goalRateNumeratorUnitsOptions;
@property (nonatomic, strong) NSArray *goalRateDenominatorUnitsOptions;

@end

@implementation RoadDialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fitbitDatasetTitles = [NSArray arrayWithObjects:@"Steps", @"Weight", @"Body Fat Percentage", @"Hours Slept", @"Active Score", nil];
    self.fitbitDatasetValues = [NSArray arrayWithObjects:@"steps", @"weight", @"body_fat", @"hours_slept", @"active_score", nil];
    [self hideFormFields];

    self.roadDialButton.hidden = YES;
    self.roadDialButton = [BeeminderAppDelegate standardGrayButtonWith:self.roadDialButton];
    self.saveGoalButton = [BeeminderAppDelegate standardGrayButtonWith:self.saveGoalButton];
    [self fetchGoalSlugs];
    [self setGoalToDefaults];
}

- (void)showDefaultFormFields
{
    self.firstLabel.hidden = YES;
    self.firstTextField.placeholder = @"Current value";
    self.firstTextField.hidden = NO;
    self.ephemSwitch.hidden = NO;
    self.ephemLabel.hidden = NO;
    self.startFlatLabel.hidden = NO;
    self.startFlatSwitch.hidden = NO;
    self.titleTextField.hidden = NO;
    self.saveGoalButton.hidden = NO;
}

- (void)hideFormFields
{
    self.firstLabel.hidden = YES;
    self.firstTextField.hidden = YES;
    self.ephemSwitch.hidden = YES;
    self.ephemLabel.hidden = YES;
    self.startFlatLabel.hidden = YES;
    self.startFlatSwitch.hidden = YES;
    self.titleTextField.hidden = YES;
    self.saveGoalButton.hidden = YES;
    self.goalWarningLabel.hidden = YES;
}

- (void)adjustForFitbit
{
    [self showDefaultFormFields];
    self.firstTextField.inputView = self.pickerView;
    self.firstLabel.text = kChooseFitbitFieldText;
    self.firstLabel.hidden = NO;
    self.firstTextField.text = @"Steps";
    self.firstLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
//    [self.firstTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSDictionary *goalTypeInfo = [[BeeminderAppDelegate goalTypesInfo] objectForKey:[BeeminderAppDelegate sharedSessionGoal].goal_type];
    self.goalTypeLabel.text = [goalTypeInfo objectForKey:kPublicNameKey];
    self.goalDetailsLabel.text = [goalTypeInfo objectForKey:kDetailsKey];
    
    if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kFitbitPrivate]) {
        if ([ABCurrentUser user].hasAuthorizedFitbit || [[NSUserDefaults standardUserDefaults] objectForKey:kFitbitAccessTokenKey]) {
            [self adjustForFitbit];
        }
        else {
            if (self.comingFromAuthorizeBeeminderView) {
                [[self navigationController] popViewControllerAnimated:YES];
            }
            else {
                self.comingFromAuthorizeBeeminderView = YES;
                [self presentAuthorizeBeeminderController];
            }
        }
    }
    else if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kDrinkerPrivate]) {
        [self showDefaultFormFields];
        self.firstLabel.hidden = NO;
        self.firstTextField.placeholder = nil;
        self.startFlatLabel.hidden = YES;
        self.startFlatSwitch.hidden = YES;
        self.firstTextField.inputView = nil;
    }
    else if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kHustlerPrivate]) {
        [self showDefaultFormFields];
        self.firstLabel.hidden = YES;
        self.firstTextField.hidden = YES;
        self.firstTextField.inputView = nil;
    }
    else if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kFatloserPrivate]) {
        [self showDefaultFormFields];
        self.startFlatLabel.hidden = YES;
        self.startFlatSwitch.hidden = YES;
        self.firstTextField.inputView = nil;
    }
    else {
        [self showDefaultFormFields];
        self.firstTextField.inputView = nil;
        self.firstTextField.placeholder = @"Current value";
        self.firstLabel.hidden = YES;
    }
    
    if ([[goalTypeInfo objectForKey:kKyoomKey] boolValue]) {
        [BeeminderAppDelegate sharedSessionGoal].initval = [NSNumber numberWithInt:0];
    }
}

- (void)showStartFlat
{
    self.startFlatLabel.hidden = NO;
    self.startFlatSwitch.hidden = NO;
    self.startFlatSwitch.on = YES;
}

- (void)hideStartFlat
{
    self.startFlatLabel.hidden = YES;
    self.startFlatSwitch.hidden = YES;
    self.startFlatSwitch.on = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)authorizeBeeminderButtonPressed
{
    [self presentAuthorizeBeeminderController];
}

- (void)presentAuthorizeBeeminderController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    AuthorizeBeeminderViewController *authCon = [storyboard instantiateViewControllerWithIdentifier:@"authorizeBeeminderViewController"];
    
    [self presentViewController:authCon animated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidUnload {
    [self setGoalTypeLabel:nil];
    [self setGoalDetailsLabel:nil];
    [self setFirstTextField:nil];
    [self setFirstLabel:nil];
    [self setStartFlatSwitch:nil];
    [self setRoadDialButton:nil];
    [self setTitleTextField:nil];
    [self setSaveGoalButton:nil];
    [self setEphemSwitch:nil];
    [self setStartFlatLabel:nil];
    [self setEphemLabel:nil];
    [self setPickerView:nil];
    [self setGoalWarningLabel:nil];
    [super viewDidUnload];
}

- (void)fetchGoalSlugs
{
    NSString *username = [ABCurrentUser username];
    
    NSArray *goals = [Goal MR_findByAttribute:@"user.username" withValue:username inContext:[NSManagedObjectContext MR_defaultContext]];
    
    Goal *g = nil;
    NSMutableArray *slugs = [[NSMutableArray alloc] init];
    
    for (g in goals) {
        [slugs addObject:g.slug];
    }
    [slugs addObject:@"new"];
    
    self.goalSlugs = [NSArray arrayWithArray:(NSArray *)slugs];
    
}

- (IBAction)titleTextFieldEditingChanged
{
    if (self.titleTextField.text) {
        self.saveGoalButton.enabled = YES;
        [self checkForExistingSlug];
    }
    else {
        self.saveGoalButton.enabled = NO;
    }
}

- (void)checkForExistingSlug
{
    BOOL exists = [self slugExistsForTitle:self.titleTextField.text];
    self.goalWarningLabel.text = @"You already have a goal with that slug";
    self.goalWarningLabel.hidden = !exists;
    self.saveGoalButton.enabled = !exists;
}

- (BOOL)slugExistsForTitle:(NSString *)title
{
    return [self.goalSlugs containsObject:[BeeminderAppDelegate slugFromTitle:title]];
}

- (id)rateFromForm
{
    Goal *goal = [BeeminderAppDelegate sharedSessionGoal];
    if ([goal.goal_type isEqualToString:kDrinkerPrivate]) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        return [numberFormatter numberFromString:self.firstTextField.text];
    }
    return nil;
}

- (NSNumber *)initialValFromForm
{
    NSDictionary *goalTypeInfo = [[BeeminderAppDelegate goalTypesInfo] objectForKey:[BeeminderAppDelegate sharedSessionGoal].goal_type];
    
    if ([[goalTypeInfo objectForKey:kKyoomKey] boolValue]) {
        return [NSNumber numberWithInt:0];
    }
    else {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        return [numberFormatter numberFromString:self.firstTextField.text];
    }
}

- (IBAction)saveGoalButtonPressed
{
    Goal *goal = [BeeminderAppDelegate sharedSessionGoal];
    goal.user = [ABCurrentUser user];
    goal.title = self.titleTextField.text;
    goal.slug = [BeeminderAppDelegate slugFromTitle:goal.title];
    goal.ephem = [NSNumber numberWithBool:self.ephemSwitch.on];
    if ([goal.goal_type isEqualToString:kFitbitPrivate]) {
        goal.fitbit = [NSNumber numberWithBool:YES];
        goal.fitbit_field = [self.fitbitDatasetValues objectAtIndex:[self.pickerView selectedRowInComponent:0]];
        if ([goal.fitbit_field isEqualToString:@"weight"] ||
            [goal.fitbit_field isEqualToString:@"body_fat"]) {
            goal.goal_type = kFatloserPrivate;
        }
        else {
            goal.goal_type = kHustlerPrivate;
        }
    }
    if ([goal.goal_type isEqualToString:kDrinkerPrivate] && !goal.rate) {
        goal.rate = [self rateFromForm];
    }
    goal.initval = [self initialValFromForm];
    
    [self parseInitialValue];
    [self parseWeeklyEstimate];
    
    BOOL errors = NO;
    
    if (!self.firstTextField.hidden && [self.firstTextField.text isEqualToString:@""]) {
        self.firstLabel.textColor = [UIColor redColor];
        self.firstLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
        errors = YES;
    }
    else {
        self.firstLabel.textColor = [UIColor blackColor];
        self.firstLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
    }
    
    if ([self.titleTextField.text isEqualToString:@""]) {
        self.goalWarningLabel.text = @"You must choose a name for your goal";
        self.goalWarningLabel.hidden = NO;
        errors = YES;
    }
    
    if (errors) {
        return;
    }
    
    if ([ABCurrentUser accessToken]) {
        [self.view endEditing:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Saving...";
        CompletionBlock successBlock = ^{
            if ([goal.fitbit boolValue]) {
                hud.labelText = @"We're importing your Fitbit data...";
                [hud setLabelFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                });
            }
            else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        };
        [goal pushToRemoteWithSuccessBlock:successBlock];
        
    }
    else {
        [self performSegueWithIdentifier:@"segueToSignup" sender:self];
    }
}

- (IBAction)startFlatSwitchValueChanged
{
    if (self.startFlatSwitch.on) {
        [self setGoalToDefaults];
        self.roadDialButton.hidden = YES;
    }
    else {
        [self presentRoadDial];
    }
}

- (void)setGoalToDefaults
{
    Goal *goal = [BeeminderAppDelegate sharedSessionGoal];
    goal.rate = [NSNumber numberWithDouble:0];
    goal.goaldate = [NSNumber numberWithDouble:[[NSDate dateWithTimeIntervalSinceNow:365*24*3600] timeIntervalSince1970]];
    goal.goalval = nil;
}

- (IBAction)roadDialButtonPressed
{
    [self presentRoadDial];
}


- (void)presentRoadDial
{
    self.roadDialButton.hidden = NO;
    self.definesPresentationContext = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    AdvancedRoalDialViewController *advCon = [storyboard instantiateViewControllerWithIdentifier:@"advancedRoadDialViewController"];
    
    advCon.goalObject = [BeeminderAppDelegate sharedSessionGoal];
    
    [self presentViewController:advCon animated:YES completion:nil];
}

- (void)parseWeeklyEstimate
{
    NSDictionary *goalTypeInfo = [[BeeminderAppDelegate goalTypesInfo] objectForKey:[BeeminderAppDelegate sharedSessionGoal].goal_type];
    
    if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kDrinkerPrivate]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *weeklyEstimate = [formatter numberFromString:self.firstTextField.text];
        [BeeminderAppDelegate sharedSessionGoal].rate = weeklyEstimate;
    }
}

- (void)parseInitialValue
{
    NSDictionary *goalTypeInfo = [[BeeminderAppDelegate goalTypesInfo] objectForKey:[BeeminderAppDelegate sharedSessionGoal].goal_type];
    if (![[goalTypeInfo objectForKey:kKyoomKey] boolValue]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *initVal = [formatter numberFromString:self.firstTextField.text];
        
        [BeeminderAppDelegate sharedSessionGoal].initval = initVal;
    }
    else {
        [BeeminderAppDelegate sharedSessionGoal].initval = [NSNumber numberWithInt:0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)firstTextFieldEditingDidBegin
{
    if (self.firstTextField.inputView == self.pickerView) {
        self.pickerView.hidden = NO;
    }
}

- (IBAction)firstTextFieldEditingDidEnd
{
    self.pickerView.hidden = YES;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.fitbitDatasetTitles count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.fitbitDatasetTitles objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.firstTextField.text = [self.fitbitDatasetTitles objectAtIndex:row];
    if ([self.firstTextField.text isEqualToString:@"Weight"] || [self.firstTextField.text isEqualToString:@"Body Fat Percentage"]) {
        [self hideStartFlat];
    }
    else {
        [self showStartFlat];
    }
}

@end
