//
//  GeneralUtilities.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "GeneralUtilities.h"
#import "Realm/Realm.h"

@implementation GeneralUtilities

+ (NSMutableArray *) mutableArrayFromRealmResults:(RLMResults *)results
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:results.count];
    
    for (RLMObject *object in results) {
        [array addObject:object];
    }
    return array;
}

@end
