//
//  UserPushRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UserPushRequest.h"

@implementation UserPushRequest

+ (UserPushRequest *)requestForUser:(User *)user pushAssociations:(BOOL)pushAssociations additionalParams:(NSDictionary *)additionalParams completionBlock:(CompletionBlock)completionBlock
{
    UserPushRequest *userPushRequest = [[UserPushRequest alloc] init];
    userPushRequest.pushAssociations = pushAssociations;
    userPushRequest.resource = user;
    userPushRequest.completionBlock = completionBlock;
    
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

    __block NSString *pString = [userPushRequest paramString];

    if (additionalParams) {
        [additionalParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
         {
             pString = [pString stringByAppendingFormat:@"%@=%@&", key, obj];
             
         }
         ];

    }
    pString = [pString stringByAppendingFormat:@"%@=%@&", @"beemios_secret", kBeemiosSecret];
    [request setHTTPBody:[pString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:userPushRequest];
    
    if (connection) {
        userPushRequest.responseData = [[NSMutableData alloc] init];
        userPushRequest.status = @"sent";
    }
    
    return userPushRequest;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    
    NSDictionary *responseJSON = [responseString JSONValue];
    NSString *accessToken = [responseJSON objectForKey:@"access_token"];
    NSString *username = [responseJSON objectForKey:@"username"];
    [ABCurrentUser loginWithUsername:username accessToken:accessToken];
    
    if (self.pushAssociations) {
        Goal *g;
        for (g in [(User *)self.resource goals]) {
            [GoalPushRequest requestForGoal:g withCompletionBlock:nil];
        }
    }
    [super connectionDidFinishLoading:connection];
}

@end
