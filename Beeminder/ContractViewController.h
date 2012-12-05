//
//  ContractViewController.h
//  Beeminder
//
//  Created by Andy Brett on 12/4/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) Goal *goalObject;
@end
