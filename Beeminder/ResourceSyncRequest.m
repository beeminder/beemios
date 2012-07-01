//
//  ResourceSyncRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourceSyncRequest.h"

@implementation ResourceSyncRequest

@synthesize status = _status;
@synthesize responseData = _responseData;
@synthesize responseStatus = _responseStatus;
@synthesize resource = _resource;

- (NSString *)paramString
{
    NSString *pString = @"?";
    
    for (NSString *key in [[self.resource.entity attributesByName] allKeys]) {
        pString = [pString stringByAppendingString:[NSString stringWithFormat:@"%@=%@?", key, [self performSelector:NSSelectorFromString(key)]]];
        
    }
    return pString;
}

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
