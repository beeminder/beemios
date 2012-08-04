//
//  ChooseGoalTypeViewController.m
//  Beeminder
//
//  Created by Andy Brett on 7/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ChooseGoalTypeViewController.h"

@interface ChooseGoalTypeViewController ()

@end

@implementation ChooseGoalTypeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *fatLoser = [NSDictionary dictionaryWithObjectsAndKeys:@"Lose Weight", @"publicName", @"fatloser", @"privateName", nil];
    
    NSDictionary *hustler = [NSDictionary dictionaryWithObjectsAndKeys:@"Do More", @"publicName", @"hustler", @"privateName", nil];
    
    NSDictionary *biker = [NSDictionary dictionaryWithObjectsAndKeys:@"Odometer", @"publicName", @"biker", @"privateName", nil];
    
    self.goalTypes = [NSArray arrayWithObjects:fatLoser, hustler, biker, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.goalTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Goal Type Cell"];
    

    cell.textLabel.text = [[self.goalTypes objectAtIndex:indexPath.row] objectForKey:@"publicName"];
    
    if ([self.goalObject.gtype isEqualToString:[[self.goalTypes objectAtIndex:indexPath.row] objectForKey:@"privateName"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.goalObject.gtype = [[self.goalTypes objectAtIndex:indexPath.row] objectForKey:@"privateName"];

//    [self.tableView reloadData];
    
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    });
    

}

@end
