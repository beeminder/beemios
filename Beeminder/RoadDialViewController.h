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

@property (nonatomic, strong) NSString *goalRateDenominatorUnits;
@property (nonatomic, strong) NSString *goalRateNumeratorUnits;
@property NSInteger goalRateNumerator;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (strong, nonatomic) IBOutlet UILabel *goalStatementLabel;

@end
