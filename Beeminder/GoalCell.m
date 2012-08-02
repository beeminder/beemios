//
//  GoalCell.m
//  Beeminder
//
//  Created by Andy Brett on 8/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "GoalCell.h"

@implementation GoalCell
@synthesize countdownDaysLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawCountdownDays
{
    self.countdownDaysLabel.text = [NSString stringWithFormat:@"%d", self.countdownDays];
    switch (self.countdownDays) {
        case -1:
            self.countdownDaysLabel.backgroundColor = [UIColor blackColor];
            break;
        case 0:
            self.countdownDaysLabel.backgroundColor = [UIColor redColor];
        case 1:
            self.countdownDaysLabel.backgroundColor = [UIColor orangeColor];
        case 2:
            self.countdownDaysLabel.backgroundColor = [UIColor blueColor];
        default:
            self.countdownDaysLabel.backgroundColor = [UIColor greenColor];
            break;
    }
}

@end
