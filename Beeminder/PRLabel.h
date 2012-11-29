//
//  PRLabel.h
//  Beeminder
//
//  Created by Andy Brett on 11/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PRLabel : UILabel

@property (strong, nonatomic, readwrite) UIView* inputView;
@property (strong, nonatomic, readwrite) UIView* inputAccessoryView;

@end
