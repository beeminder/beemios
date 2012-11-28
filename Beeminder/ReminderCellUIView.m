//
//  ReminderCellUIView.m
//  Beeminder
//
//  Created by Andy Brett on 11/27/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ReminderCellUIView.h"

@implementation ReminderCellUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = [UIColor lightGrayColor].CGColor;
        CALayer *topBorder = [CALayer layer];
        topBorder.borderColor = self.borderColor;
        topBorder.borderWidth = 1;
        topBorder.frame = CGRectMake(-1, -1, self.frame.size.width + 2, 1);
        [self.layer addSublayer:topBorder];
        
        CALayer *leftBorder = [CALayer layer];
        leftBorder.borderColor = self.borderColor;
        leftBorder.borderWidth = 1;
        leftBorder.frame = CGRectMake(-1, 0, 1, self.frame.size.height);
        [self.layer addSublayer:leftBorder];
        
        CALayer *rightBorder = [CALayer layer];
        rightBorder.borderColor = self.borderColor;
        rightBorder.borderWidth = 1;
        rightBorder.frame = CGRectMake(self.frame.size.width, 0, 1, self.frame.size.height);
        [self.layer addSublayer:rightBorder];
        // Initialization code
    }
    return self;
}

- (id)initWithY:(float)y
{
    return [[ReminderCellUIView alloc] initWithFrame:CGRectMake(20.0f, y, 280.0f, 50.0f)];
}

- (id)initWithY:(float)y andBottomBorder:(BOOL)bottomBorder
{
    ReminderCellUIView *view = [[ReminderCellUIView alloc] initWithY:y];
    if (bottomBorder) {
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.borderColor = view.borderColor;
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRectMake(-1, view.frame.size.height, view.frame.size.width + 2, 1);
        [view.layer addSublayer:bottomBorder];
    }
    return view;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
