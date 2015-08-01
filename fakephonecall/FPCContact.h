//
//  FPCContact.h
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Realm/Realm.h>

@interface FPCContact : RLMObject

@property NSInteger contactId;
@property NSString *name;
@property NSString *number;
@property NSInteger timesCalled;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<FPCContact>
RLM_ARRAY_TYPE(FPCContact)
