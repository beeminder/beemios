//
//  ResourceSyncRequest.m
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "ResourcePushRequest.h"

@implementation ResourcePushRequest

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
    if (self.responseStatus != 200 && [self.resource isKindOfClass:[Goal class]]) {
        Goal *goal = (Goal *)self.resource;
        if (!goal.serverId) {
            [[NSManagedObjectContext MR_defaultContext] deleteObject:self.resource];
            [[NSManagedObjectContext MR_defaultContext] MR_save];
        }

    }
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.status = @"failed";
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.status = @"returned";
    if (self.completionBlock) dispatch_async(dispatch_get_current_queue(), self.completionBlock);
}


@end
