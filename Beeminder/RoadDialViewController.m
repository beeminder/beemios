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
    self.goalSlugExistsWarningLabel.hidden = YES;
    self.roadDialButton.hidden = YES;
    self.roadDialButton = [BeeminderAppDelegate standardGrayButtonWith:self.roadDialButton];
    self.saveGoalButton = [BeeminderAppDelegate standardGrayButtonWith:self.saveGoalButton];
    
    [self fetchGoalSlugs];
    [self setGoalToDefaults];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSDictionary *goalTypeInfo = [[BeeminderAppDelegate goalTypesInfo] objectForKey:[BeeminderAppDelegate sharedSessionGoal].goal_type];
    self.goalTypeLabel.text = [goalTypeInfo objectForKey:kPublicNameKey];
    self.goalDetailsLabel.text = [goalTypeInfo objectForKey:kDetailsKey];
    
    if ([[goalTypeInfo objectForKey:kKyoomKey] boolValue]) {
        [BeeminderAppDelegate sharedSessionGoal].initval = [NSNumber numberWithInt:0];
    }

    if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kDrinkerPrivate]) {
        [self.firstLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.0]];
        self.firstLabel.text = kWeeklyEstimateText;
        self.startFlatLabel.hidden = YES;
        self.startFlatSwitch.hidden = YES;
    }
    else {
        [self.firstLabel setFont:[UIFont fontWithName:@"Helvetica" size:17.0]];
        self.firstLabel.text = @"Current value:";
    }
    
    if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kHustlerPrivate]) {
        self.firstLabel.hidden = YES;
        self.firstTextField.hidden = YES;
    }
    
    if ([[goalTypeInfo objectForKey:kPrivateNameKey] isEqualToString:kFatloserPrivate]) {
        self.startFlatLabel.hidden = YES;
        self.startFlatSwitch.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self setTitleLabel:nil];
    [self setSaveGoalButton:nil];
    [self setGoalSlugExistsWarningLabel:nil];
    [self setEphemSwitch:nil];
    [self setStartFlatLabel:nil];
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
    self.goalSlugExistsWarningLabel.hidden = !exists;
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
        self.titleLabel.textColor = [UIColor redColor];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
        errors = YES;
    }
    else {
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
    }
    
    if (errors) {
        return;
    }
    
    if ([ABCurrentUser accessToken]) {
        [self.view endEditing:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Saving...";
        CompletionBlock successBlock = ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [[[self navigationController] presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            [[NSManagedObjectContext MR_defaultContext] MR_save];            
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

@end
