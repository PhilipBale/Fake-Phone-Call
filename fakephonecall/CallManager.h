//
//  CallManager.h
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPCUser.h"

@interface CallManager : NSObject

+ (CallManager *)sharedManager;

- (void) placeCallForUser:(FPCUser *)user toNumber:(NSString *)number when:(NSInteger)when success:(void (^)(BOOL))success;

@end
