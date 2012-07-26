//
//  ResourceSyncRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourcePushRequest.h"

@implementation ResourcePushRequest

@synthesize status = _status;
@synthesize responseData = _responseData;
@synthesize responseStatus = _responseStatus;
@synthesize resource = _resource;

- (NSString *)paramString
{
    NSString *pString = @"";
    
    for (NSString *key in [[self.resource.entity attributesByName] allKeys]) {
        id val = [self.resource performSelector:NSSelectorFromString(key)];
        if (val) {
            pString = [pString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, val]];
        }
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
    dispatch_async(dispatch_get_current_queue(), self.completionBlock);
}


@end
