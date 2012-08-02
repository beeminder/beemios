//
//  GoalCell.h
//  Beeminder
//
//  Created by Andy Brett on 8/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoalCell : UITableViewCell

@property int countdownDays;

- (void)drawCountdownDays;
@property (strong, nonatomic) IBOutlet UILabel *countdownDaysLabel;

@end
