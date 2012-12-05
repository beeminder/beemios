//
//  AuthorizeBeeminderViewController.h
//  Beeminder
//
//  Created by Andy Brett on 11/16/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoadDialViewController.h"

@interface AuthorizeBeeminderViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) RoadDialViewController *rdvCon;

@end
