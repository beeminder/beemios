//
//  ResourceSyncRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ResourcePushRequest : NSObject <NSURLConnectionDelegate>

@property NSUInteger responseStatus;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSManagedObject *resource;
@property (strong, nonatomic) NSString *status;
@property BOOL pushAssociations;
@property (strong, nonatomic) NSString *segueIdentifier;
@property (strong, nonatomic) UIViewController *segueFromViewController;

- (NSString *)paramString;

@end
