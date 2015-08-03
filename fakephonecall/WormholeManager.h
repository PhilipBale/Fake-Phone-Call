//
//  WormholeManager.h
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMWormhole.h"

@interface WormholeManager : NSObject

@property (nonatomic, strong) MMWormhole *wormhole;

+ (WormholeManager *)sharedManager;

@end
