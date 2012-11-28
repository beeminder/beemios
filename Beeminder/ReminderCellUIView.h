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

- (id)initWithY:(float)y;
- (id)initWithY:(float)y andBottomBorder:(BOOL)bottomBorder;


@end
