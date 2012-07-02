//
//  ResourcePullRequest.h
//  Beeminder
//
//  Created by Andy Brett on 7/1/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ResourcePullRequest : NSObject <NSURLConnectionDelegate>

@property NSUInteger responseStatus;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSManagedObjectContext *context;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
