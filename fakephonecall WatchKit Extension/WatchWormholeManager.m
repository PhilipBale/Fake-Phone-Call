//
//  WatchWormholeManager.m
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "WatchWormholeManager.h"
#import "MMWormhole.h" 

@interface WatchWormholeManager ()
@property MMWormhole *wormhole;
@end

@implementation WatchWormholeManager

+ (WatchWormholeManager *)sharedManager
{
    static dispatch_once_t pred;
    static WatchWormholeManager *_sharedManager = nil;
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}

-(instancetype)init
{
    self = [super self];
    if (self)
    {
        NSLog(@"Initializing Watch wormhole");
        self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.logikcomputing.fakephonecall" optionalDirectory:@"wormhole"];
        }
    
    return self;
}

- (void)placeCallWithNumber:(NSString *)number when:(NSNumber *)when
{
    NSLog(@"Placing watch call to wormhole");
    [self.wormhole passMessageObject:@{@"number" : number, @"when":when}  identifier:@"callPlaced"];
}
                             
@end