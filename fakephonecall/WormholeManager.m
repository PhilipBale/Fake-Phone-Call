//
//  WormholeManager.m
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "WormholeManager.h" 
#import "FPCManager.h"

@interface WormholeManager ()

@end

@implementation WormholeManager

+ (WormholeManager *)sharedManager
{
    static dispatch_once_t pred;
    static WormholeManager *_sharedManager = nil;
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}

-(instancetype)init
{
    self = [super self];
    if (self)
    {
        NSLog(@"Initializing client wormhole");
        self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:@"group.logikcomputing.fakephonecall" optionalDirectory:@"wormhole"];
        [self.wormhole listenForMessageWithIdentifier:@"callPlaced" listener:^(id messageObject) {
            NSLog(@"Call placed received from wormhole");
            [[FPCManager sharedManager] placeCallToNumber:[messageObject objectForKey:@"number"] when:[[messageObject objectForKey:@"when"] integerValue] completion:^(BOOL success){
                NSLog(@"Posting nsnotification center notice that wormhole call placed");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wormholeCallPlaced" object:nil];
            }];
        }];
    }
    
    return self;
}

@end
