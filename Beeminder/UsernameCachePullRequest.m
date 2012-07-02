//
//  UsernameCachePullRequest.m
//  Beeminder
//
//  Created by Andy Brett on 7/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UsernameCachePullRequest.h"

@implementation UsernameCachePullRequest

+ (UsernameCachePullRequest *)requestInContext:(NSManagedObjectContext *)context
{
    UsernameCachePullRequest *usernameCachePullRequest = [[UsernameCachePullRequest alloc] init];
    
    NSFetchRequest *cacheRequest = [NSFetchRequest fetchRequestWithEntityName:@"UsernameCache"];
    
    NSArray *results = [context executeFetchRequest:cacheRequest error:nil];
    
    usernameCachePullRequest.context = context;

    NSString *urlString;
    
    if ([results lastObject]) {
        urlString = [[results lastObject] readURL];
        usernameCachePullRequest.usernameCache = [results lastObject];
    }
    else {
        urlString = [UsernameCache readURL];
        usernameCachePullRequest.usernameCache = [NSEntityDescription insertNewObjectForEntityForName:@"UsernameCache" inManagedObjectContext:context];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:usernameCachePullRequest];
    
    if (connection) {
        usernameCachePullRequest.responseData = [NSMutableData data];
        usernameCachePullRequest.status = @"sent";
    }
    
    return usernameCachePullRequest;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    
    NSDictionary *responseJSON = [responseString JSONValue];
    
    NSArray *usernames = [responseJSON objectForKey:@"usernames"];
    
    NSString *csv = [usernames componentsJoinedByString:@","];
    
    self.usernameCache.usernameList = csv;

    [self.context save:nil];
    
}

@end
