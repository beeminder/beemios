//
//  UserPushRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UserPushRequest.h"

@implementation UserPushRequest

+ (UserPushRequest *)requestForUser:(User *)user syncAssociations:(BOOL)syncAssociations
{
    UserPushRequest *userPushRequest = [[UserPushRequest alloc] init];
    userPushRequest.resource = user;
    NSString *urlString;
    
    if (user.serverId) {
        urlString = [user updateURL];
    }
    else {
        urlString = [user createURL];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[userPushRequest paramString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:userPushRequest];
    
    if (connection) {
        userPushRequest.status = @"sent";
    }
    
    return userPushRequest;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.status = @"returned";
}

@end
