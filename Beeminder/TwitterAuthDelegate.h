//
//  TwitterAuthDelegate.h
//  Beeminder
//
//  Created by Andy Brett on 11/25/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterAuthDelegate <NSObject>

- (void)getReverseAuthTokensForTwitterAccount:(ACAccount *)twitterAccount;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) ACAccount *selectedTwitterAccount;

@end
