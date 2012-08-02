//
//  ChooseGoalNameViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/22/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ChooseGoalNameViewController.h"
#import "Goal+Resource.h"
#import "RoadDialViewController.h"

@interface ChooseGoalNameViewController ()

- (void)fetchGoalSlugs;

@end

@implementation ChooseGoalNameViewController

@synthesize goalNameTextField = _goalNameTextField;
@synthesize submitButton = _submitButton;
@synthesize scrollView = _scrollView;
@synthesize activeField = _activeField;
@synthesize goalSlugs = _goalSlugs;
@synthesize goalSlugExistsWarningLabel = _goalSlugExitsWarningLabel;
@synthesize helperLabel = _helperLabel;
@synthesize ephemSwitch = _ephemSwitch;

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
    [self fetchGoalSlugs];
    
    UILabel *welcome = nil;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"]){
        welcome = [[UILabel alloc] initWithFrame:CGRectMake(20, 146, 280, kLoggedInChooseGoalHeight)];
        
        welcome.text = kLoggedInChooseGoalName;
        [self.goalNameTextField becomeFirstResponder];
    }
    else {
        welcome = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, kWelcomeChooseGoalHeight)];
        
        welcome.text = kWelcomeChooseGoalName;
    }
    
    [welcome setNumberOfLines:0];
    [self.view addSubview:welcome];
    [self registerForKeyboardNotifications];
}

- (void)viewDidUnload
{
    [self setGoalNameTextField:nil];
    [self setSubmitButton:nil];
    [self setScrollView:nil];
    [self setGoalSlugExistsWarningLabel:nil];
    [self setEphemSwitch:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)fetchGoalSlugs
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    NSArray *goals = [Goal MR_findByAttribute:@"user.username" withValue:username];
    
    Goal *g = nil;
    NSMutableArray *slugs = [[NSMutableArray alloc] init];
    
    for (g in goals) {
        [slugs addObject:g.slug];
    }
    [slugs addObject:@"new"];
    
    self.goalSlugs = [NSArray arrayWithArray:(NSArray *)slugs];
    
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
    CGPoint origin = self.goalSlugExistsWarningLabel.frame.origin;
    CGFloat height = self.goalSlugExistsWarningLabel.frame.size.height;
    CGFloat buffer = 10.0;
    origin.y -= self.scrollView.contentOffset.y;
    origin.y += height;
    origin.y += buffer;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.goalSlugExistsWarningLabel.frame.origin.y - (aRect.size.height) + height + buffer); 
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (IBAction)checkForExistingSlug 
{
    BOOL exists = [self slugExistsForTitle:self.goalNameTextField.text];
    self.goalSlugExistsWarningLabel.hidden = !exists;
    self.submitButton.enabled = !exists;
}

- (BOOL)slugExistsForTitle:(NSString *)title
{
    return [self.goalSlugs containsObject:[self slugFromTitle:title]];
}

- (NSString *)slugFromTitle:(NSString *)title
{
    NSRegularExpression *whitespaceRegex = [NSRegularExpression regularExpressionWithPattern:@"[\\s]" options:0 error:nil];
    
    NSString *noSpaces = [whitespaceRegex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, title.length) withTemplate:@"-"];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\-\\_]" options:0 error:nil];
    
    NSString *slug = [regex stringByReplacingMatchesInString:noSpaces options:0 range:NSMakeRange(0, noSpaces.length) withTemplate:@""];
    
    return slug;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *slug = [self slugFromTitle:self.goalNameTextField.text];
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext]; 
    
    Goal *goal = [Goal MR_createEntity];
    goal.title = self.goalNameTextField.text;
    goal.slug = slug;
    User *user = [User MR_findFirstByAttribute:@"username" withValue:username];
    goal.user = user;
    goal.ephem = [NSNumber numberWithBool:self.ephemSwitch.on];
    goal.gtype = @"hustler";
    
    [defaultContext MR_save];
    
    [segue.destinationViewController setTitle:self.goalNameTextField.text];
    [segue.destinationViewController setGoalObject:goal];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    if ([self slugExistsForTitle:textField.text]) {
        return NO;
    }
    else {
        [textField resignFirstResponder];
        [self.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside]; //press button
        return YES;
    }
}

@end
