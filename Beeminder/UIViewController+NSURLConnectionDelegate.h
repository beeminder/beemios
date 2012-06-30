//
//  UIViewController+NSURLConnectionDelegate.h
//  Beeminder
//
//  Created by Andy Brett on 6/29/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DejalActivityView.h"

@interface UIViewController (NSURLConnectionDelegate)

@property (strong, nonatomic) NSMutableData *responseData;
@property NSInteger responseStatus;

@end
