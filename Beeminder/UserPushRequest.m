//
//  UserPushRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UserPushRequest.h"

@implementation UserPushRequest

+ (UserPushRequest *)requestForUser:(User *)user pushAssociations:(BOOL)pushAssociations additionalParams:(NSDictionary *)additionalParams successBlock:(CompletionBlock)successBlock errorBlock:(CompletionBlock)errorBlock
{
    UserPushRequest *userPushRequest = [[UserPushRequest alloc] init];
    
    NSURL *url;
    NSMutableURLRequest *request;
    if (user.serverId) {
        url = [NSURL URLWithString:[user updateURL]];
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"PUT"];
    }
    else {
        url = [NSURL URLWithString:[user createURL]];
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
    }
    
    NSDictionary *allParams = [user paramsDict];
    
    if (additionalParams) {
        allParams = [NSDictionary dictionaryByMerging:allParams with:additionalParams];
    }

    
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
    
    NSArray *keys = [allParams allKeys];
    
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    __block NSString *pString = @"";
    
    [sortedKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        pString = [pString stringByAppendingFormat:@"&%@=%@", key, AFURLEncodedStringFromStringWithEncoding([allParams objectForKey:key], NSUTF8StringEncoding)];
    }];
    
    // remove first & character
    pString = [pString substringFromIndex:1];
    
    pString = [pString stringByAppendingFormat:@"&beemios_token=%@",  AFURLEncodedStringFromStringWithEncoding([BeeminderAppDelegate hmacSha1SignatureForBaseString:pString andKey:kBeemiosSigningKey], NSUTF8StringEncoding)];
    
    [request setHTTPBody:[pString dataUsingEncoding:NSUTF8StringEncoding]];
    

    AFJSONRequestOperation *afRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (response.statusCode == 200) {
            NSString *accessToken = [JSON objectForKey:@"access_token"];
            NSString *username = [JSON objectForKey:@"username"];
            [ABCurrentUser loginWithUsername:username accessToken:accessToken];
            
            if (pushAssociations) {
                for (Goal *g in user.goals) {
                    [GoalPushRequest requestForGoal:g];
                }
            }
            if (successBlock) successBlock();
        }
        else {
            if (errorBlock) errorBlock();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
        NSLog(@"%@", response);
        if (errorBlock) errorBlock();
    }];

    [afRequest start];
    
    return userPushRequest;
}

@end
