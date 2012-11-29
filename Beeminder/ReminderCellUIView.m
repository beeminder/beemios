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
        self.borderWidth = 1.0f;
        
        self.topBorder = [CALayer layer];
        self.topBorder.borderColor = self.borderColor;
        self.topBorder.borderWidth = self.borderWidth;
        self.topBorder.frame = CGRectMake(-1*self.borderWidth, -1*self.borderWidth, self.frame.size.width + 2*self.borderWidth, self.borderWidth);
        [self.layer addSublayer:self.topBorder];
        
        self.leftBorder = [CALayer layer];
        self.leftBorder.borderColor = self.borderColor;
        self.leftBorder.borderWidth = 1;
        self.leftBorder.frame = CGRectMake(-1*self.borderWidth, 0, self.borderWidth, self.frame.size.height);
        [self.layer addSublayer:self.leftBorder];
        
        self.rightBorder = [CALayer layer];
        self.rightBorder.borderColor = self.borderColor;
        self.rightBorder.borderWidth = self.borderWidth;
        self.rightBorder.frame = CGRectMake(self.frame.size.width, 0, self.borderWidth, self.frame.size.height);
        [self.layer addSublayer:self.rightBorder];
        
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.borderColor = self.borderColor;
        self.bottomBorder.borderWidth = self.borderWidth;
        self.bottomBorder.frame = CGRectMake(-1*self.borderWidth, self.frame.size.height, self.frame.size.width + 2, self.borderWidth);
        [self.layer addSublayer:self.bottomBorder];
    }
    return self;
}

- (id)initWithYPosition:(float)y
{
    return [[ReminderCellUIView alloc] initWithFrame:CGRectMake(20.0f, y, 280.0f, 50.0f)];
}

- (id)initWithYPosition:(float)y showBottomBorder:(BOOL)bottomBorder
{
    ReminderCellUIView *view = [[ReminderCellUIView alloc] initWithYPosition:y];
    view.bottomBorder.hidden = !bottomBorder;

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
