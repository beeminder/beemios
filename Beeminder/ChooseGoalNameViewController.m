//
//  ChooseGoalNameViewController.m
//  Beeminder
//
//  Created by Andy Brett on 6/22/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ChooseGoalNameViewController.h"
#import "Goal+Create.h"
#import "RoadDialViewController.h"
#import "constants.h"

@interface ChooseGoalNameViewController ()

- (void)fetchGoalSlugs;

@end

@implementation ChooseGoalNameViewController

@synthesize goalNameTextField = _goalNameTextField;
@synthesize submitButton = _submitButton;
@synthesize scrollView = _scrollView;
@synthesize activeField = _activeField;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize goalSlugs = _goalSlugs;
@synthesize goalSlugExitsWarningLabel = _goalSlugExitsWarningLabel;
@synthesize helperLabel = _helperLabel;

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
    [self registerForKeyboardNotifications];
    [self fetchGoalSlugs];
    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 176)];
    
    welcome.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"authenticationTokenKey"] ? kLoggedInChooseGoalName : kWelcomeChooseGoalName;
    
    [welcome setNumberOfLines:0];
    [self.view addSubview:welcome];
}

- (void)viewDidUnload
{
    [self setGoalNameTextField:nil];
    [self setSubmitButton:nil];
    [self setScrollView:nil];
    [self setGoalSlugExitsWarningLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)fetchGoalSlugs
{
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];    
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Goal"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"user.username = %@", username];
    
    NSArray *goals = [self.managedObjectContext executeFetchRequest:request error:NULL];
    
    self.goalSlugs = [goals valueForKey:@"slug"];
    
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
    CGPoint origin = self.goalSlugExitsWarningLabel.frame.origin;
    CGFloat height = self.goalSlugExitsWarningLabel.frame.size.height;
    CGFloat buffer = 10.0;
    origin.y -= self.scrollView.contentOffset.y;
    origin.y += height;
    origin.y += buffer;
    if (!CGRectContainsPoint(aRect, origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.goalSlugExitsWarningLabel.frame.origin.y - (aRect.size.height) + height + buffer); 
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
    self.goalSlugExitsWarningLabel.hidden = !exists;
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
    
    NSDictionary *goalDict = [NSDictionary dictionaryWithObjectsAndKeys:self.goalNameTextField.text, @"title", slug, @"slug", nil];    
    
    Goal *goal = [Goal goalWithDictionary:goalDict forUserWithUsername:username inManagedObjectContext:self.managedObjectContext];
    [segue.destinationViewController setTitle:self.goalNameTextField.text];
    [segue.destinationViewController setGoalObject:goal];
    [segue.destinationViewController setManagedObjectContext:self.managedObjectContext];
    
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
