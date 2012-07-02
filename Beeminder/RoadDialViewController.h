//
//  RoadDialViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Goal+Resource.h"
#import "UIViewController+ManagedObjectContext.h"
#import "GoalsTableViewController.h"
#import "constants.h"
#import "UIViewController+NSURLConnectionDelegate.h"

@interface RoadDialViewController : UIViewController
    <UIPickerViewDataSource,
     UIPickerViewDelegate>

@property (nonatomic, strong) NSString *goalRateDenominatorUnits;
@property (nonatomic, strong) NSString *goalRateNumeratorUnits;
@property NSInteger goalRateNumerator;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) IBOutlet UIPickerView *goalRateNumeratorPickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *goalRateDenominatorPickerView;
@property (strong, nonatomic) NSMutableData *responseData;
@property NSInteger responseStatus;

@end
