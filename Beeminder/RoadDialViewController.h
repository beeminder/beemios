//
//  RoadDialViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/20/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoadDialViewController : UIViewController 
    <UIPickerViewDataSource,
     UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *goalRateTextField;
@property (strong, nonatomic) IBOutlet UITextField *goalUnitsTextField;
@property (strong, nonatomic) IBOutlet UIPickerView *goalUnitsPicker;

- (IBAction)goalRateStepperChanged;


@end
