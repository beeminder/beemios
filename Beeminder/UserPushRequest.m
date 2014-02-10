//
//  UserPushRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UserPushRequest.h"

@implementation UserPushRequest

+ (void)requestForUser:(User *)user pushAssociations:(BOOL)pushAssociations additionalParams:(NSDictionary *)additionalParams successBlock:(CompletionBlock)successBlock errorBlock:(CompletionBlock)errorBlock
{
    NSDictionary *allParams = [user paramsDict];
    
    NSString *url = user.serverId ? [user updateURL] : [user createURL];
    if (user.serverId) {
        allParams = [allParams dictionaryByMergingWith:[NSDictionary dictionaryWithObjectsAndKeys:@"PUT", @"_method", nil]];
    }
    
    if (additionalParams) allParams = [NSDictionary dictionaryByMerging:allParams with:additionalParams];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTwitterOAuthTokenKey]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *twitterParams = [NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:kTwitterOAuthTokenKey], @"twitter_oauth_token", [defaults objectForKey:kTwitterOAuthTokenSecretKey], @"twitter_oauth_token_secret", [defaults objectForKey:kTwitterUserIdKey], @"oauth_user_id", [defaults objectForKey:kTwitterScreenNameKey], @"twitter_screen_name", nil];
        allParams = [NSDictionary dictionaryByMerging:allParams with:twitterParams];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kFacebookOAuthTokenKey]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *facebookParams = [NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:kFacebookOAuthTokenKey], @"facebook_access_token", [defaults objectForKey:kFacebookUsernameKey], @"facebook_username", [defaults objectForKey:kFacebookUserIdKey], @"oauth_user_id", nil];
        allParams = [NSDictionary dictionaryByMerging:allParams with:facebookParams];
    }
    
    BeeminderAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.operationManager POST:url parameters:allParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == 200) {
            NSString *accessToken = [responseObject objectForKey:@"access_token"];
            NSString *username = [responseObject objectForKey:@"username"];
            [ABCurrentUser loginWithUsername:username accessToken:accessToken];
            
            if (pushAssociations) {
                for (Goal *g in user.goals) {
                    if ([[additionalParams objectForKey:@"safety_buffer"] isEqualToString:@"true"]) {
                        [GoalPushRequest requestForGoal:g additionalParams: [NSDictionary dictionaryWithObjectsAndKeys:@"true", @"safety_buffer", nil] withSuccessBlock: nil];
                    }
                    else {
                        [GoalPushRequest requestForGoal:g];
                    }
                }
            }
            if (successBlock) successBlock();
        }
        else {
            if (errorBlock) errorBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock) errorBlock();
    }];
}

@end
