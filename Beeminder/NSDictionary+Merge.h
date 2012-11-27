//
//  NSDictionary+Merge.h
//  Beeminder
//
//  Created by Andy Brett on 11/27/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Merge)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2;
- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict;

@end
