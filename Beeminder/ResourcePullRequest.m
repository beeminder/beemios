//
//  ResourcePullRequest.m
//  Beeminder
//
//  Created by Andy Brett on 7/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourcePullRequest.h"

@implementation ResourcePullRequest

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.status = @"received response";
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.responseStatus = [httpResponse statusCode];
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    [self.responseData appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.status = @"failed";
    
    //    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
    //        message:[error localizedDescription]
    //        delegate:nil
    //        cancelButtonTitle:NSLocalizedString(@"OK", @"")
    //                      otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.status = @"returned";
}


@end
