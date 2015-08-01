//
//  CallManager.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "CallManager.h"

@interface CallManager ()

@end

@implementation CallManager

+ (CallManager *)sharedManager
{
    static dispatch_once_t pred;
    static CallManager *_sharedManager = nil;
    
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}

- (void) placeCallForUser:(FPCUser *)user toNumber:(NSString *)number when:(NSInteger)when success:(void (^)(BOOL))success
{
    if (success) {
        success(YES);
    }
}

@end
