//
//  ReminderCellUIView.h
//  Beeminder
//
//  Created by Andy Brett on 11/27/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderCellUIView : UIView

@property CGColorRef borderColor;
@property float borderWidth;
@property CALayer *topBorder;

@property CALayer *rightBorder;
@property CALayer *leftBorder;
@property CALayer *bottomBorder;

- (id)initWithYPosition:(float)y;
- (id)initWithYPosition:(float)y showBottomBorder:(BOOL)bottomBorder;


@end
