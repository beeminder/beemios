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
    
    NSString *urlString;
    
    if ([user.serverId intValue] == 0) {
        urlString = [user createURL];
    }
    else {
        urlString = [user updateURL];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

    __block NSString *pString = [userPushRequest paramString];

    if (additionalParams) {
        [additionalParams enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop)
         {
             pString = [pString stringByAppendingFormat:@"%@=%@&", key, obj];
             
         }
         ];

    }
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
    self.status = @"returned";

    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    
    NSDictionary *responseJSON = [responseString JSONValue];
    NSString *authenticationToken = [responseJSON objectForKey:@"authentication_token"];
    NSString *username = [responseJSON objectForKey:@"username"];
    
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    
    [[NSUserDefaults standardUserDefaults] setObject:authenticationToken forKey:@"authenticationTokenKey"];
    
    if (self.pushAssociations) {
        Goal *g;
        for (g in [(User *)self.resource goals]) {
            [GoalPushRequest requestForGoal:g];
        }
    }
    
    dispatch_async(dispatch_get_current_queue(), self.completionBlock);
}

@end
