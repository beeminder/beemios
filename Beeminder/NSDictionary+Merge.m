//
//  NSDictionary+Merge.m
//  Beeminder
//
//  Created by Andy Brett on 11/27/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2 {
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    
    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary * newVal = [[dict1 objectForKey: key] dictionaryByMergingWith: (NSDictionary *) obj];
            [result setObject: newVal forKey: key];
        } else {
            [result setObject: obj forKey: key];
        }
    }];
    
    return (NSDictionary *) [result mutableCopy];
}
- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict {
    return [[self class] dictionaryByMerging: self with: dict];
}

@end
