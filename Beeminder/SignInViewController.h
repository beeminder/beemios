//
//  SignInViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property NSMutableData *responseData;
@property NSInteger responseStatus;

@end
