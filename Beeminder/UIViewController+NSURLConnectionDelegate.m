//
//  UIViewController+NSURLConnectionDelegate.m
//  Beeminder
//
//  Created by Andy Brett on 6/29/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "UIViewController+NSURLConnectionDelegate.h"

@implementation UIViewController (NSURLConnectionDelegate)

@dynamic responseData;
@dynamic responseStatus;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
        message:[error localizedDescription]
        delegate:nil
        cancelButtonTitle:NSLocalizedString(@"OK", @"")
        otherButtonTitles:nil] show];
}

@end
