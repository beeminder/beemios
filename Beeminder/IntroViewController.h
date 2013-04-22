//
//  IntroViewController.h
//  Beeminder
//
//  Created by Andy Brett on 12/15/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashViewController.h"

@interface IntroViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) IBOutlet UILabel *para1;
@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UILabel *para2;
@property (strong, nonatomic) IBOutlet UILabel *para3;

@end
