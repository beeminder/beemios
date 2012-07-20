//
//  ResourceSyncRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef void (^CompletionBlock)();

@interface ResourcePushRequest : NSObject <NSURLConnectionDelegate>

@property NSUInteger responseStatus;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSManagedObject *resource;
@property (strong, nonatomic) NSString *status;
@property BOOL pushAssociations;
@property (strong, nonatomic) CompletionBlock completionBlock;

- (NSString *)paramString;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end