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

    __block NSString *pString = [user paramString];

    if (additionalParams) {
        [additionalParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
             pString = [pString stringByAppendingFormat:@"&%@=%@", key, obj];
         }];
    }
    pString = [pString stringByAppendingFormat:@"&%@=%@", @"beemios_secret", kBeemiosSecret];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kTwitterOAuthTokenKey]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        pString = [pString stringByAppendingFormat:@"&twitter_oauth_token=%@&twitter_oauth_token_secret=%@&twitter_user_id=%@&twitter_screen_name=%@", [defaults objectForKey:kTwitterOAuthTokenKey], [defaults objectForKey:kTwitterOAuthTokenSecretKey], [defaults objectForKey:kTwitterUserIdKey], [defaults objectForKey:kTwitterScreenNameKey]];
    }
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

//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
//    
//    NSDictionary *responseJSON = [responseString JSONValue];
//    NSString *accessToken = [responseJSON objectForKey:@"access_token"];
//    NSString *username = [responseJSON objectForKey:@"username"];
//    [ABCurrentUser loginWithUsername:username accessToken:accessToken];
//    
//    if (self.pushAssociations) {
//        Goal *g;
//        for (g in [(User *)self.resource goals]) {
//            [GoalPushRequest requestForGoal:g withCompletionBlock:nil];
//        }
//    }
//    [super connectionDidFinishLoading:connection];
//}

@end
