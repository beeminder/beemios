//
//  BeeminderViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeeminderViewController : UINavigationController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
