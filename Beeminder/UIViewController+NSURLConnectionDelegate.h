//
//  UIViewController+NSURLConnectionDelegate.h
//  Beeminder
//
//  Created by Andy Brett on 6/29/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (NSURLConnectionDelegate)

@property (strong, nonatomic) NSMutableData *responseData;
@property NSInteger responseStatus;

@end
