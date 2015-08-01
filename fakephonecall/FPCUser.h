//
//  FPCUser.h
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Realm/Realm.h>

@interface FPCUser : RLMObject

@property NSInteger userId;
@property NSString *email;
@property NSString *token;
@property NSString *name;
@property NSInteger callsPlaced;
@property NSInteger callsRemaining;
@property BOOL admin;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<FPCUser>
RLM_ARRAY_TYPE(FPCUser)
