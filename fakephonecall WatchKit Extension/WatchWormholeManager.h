//
//  WatchWormholeManager.h
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WatchWormholeManager : NSObject

+ (WatchWormholeManager *)sharedManager;
- (void)placeCallWithNumber:(NSString *)number when:(NSNumber *)when;

@end
