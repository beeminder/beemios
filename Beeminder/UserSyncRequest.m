//
//  UserSyncRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UserSyncRequest.h"

@implementation UserSyncRequest

+ (UserSyncRequest *)requestForUser:(User *)user
{
    UserSyncRequest *userSyncRequest = [[UserSyncRequest alloc] init];
    userSyncRequest.resource = user;
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
    [request setHTTPBody:[[userSyncRequest paramString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:userSyncRequest];
    
    if (connection) {
        userSyncRequest.status = @"sent";
    }
    
    return userSyncRequest;
}

@end
