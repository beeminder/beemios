//
//  UIViewController+ManagedObjectContext.m
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UIViewController+ManagedObjectContext.h"
#import "BeeminderViewController.h"

@implementation UIViewController (ManagedObjectContext)

- (NSManagedObjectContext *)managedObjectContext
{
    BeeminderViewController *beeCon = (BeeminderViewController *)self.navigationController;
    return [beeCon managedObjectContext];
}

@end
