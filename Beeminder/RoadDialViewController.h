//
//  RoadDialViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Goal.h"
@interface RoadDialViewController : UIViewController 
    <UIPickerViewDataSource,
     UIPickerViewDelegate>

@property (nonatomic, strong) NSString *goalRateDenominatorUnits;
@property (nonatomic, strong) NSString *goalRateNumeratorUnits;
@property NSInteger goalRateNumerator;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (strong, nonatomic) Goal *goalObject;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIPickerView *goalRateNumeratorPickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *goalRateDenominatorPickerView;

@end
