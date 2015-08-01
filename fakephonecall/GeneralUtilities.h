//
//  GeneralUtilities.h
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm/Realm.h"

@interface GeneralUtilities : NSObject

+ (NSMutableArray *) mutableArrayFromRealmResults:(RLMResults *)results;

@end
