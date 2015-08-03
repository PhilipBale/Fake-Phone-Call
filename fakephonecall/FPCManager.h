//
//  SharedDataManager.h
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FPCUser.h"

@interface FPCManager : NSObject

@property (nonatomic, strong) FPCUser *currentUser;

+ (FPCManager *)sharedManager;

- (void)placeCallToNumber:(NSString *)number when:(NSInteger)when completion:(void (^)(BOOL))completion;

- (void)loginOrRegisterWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name completion:(void (^)(BOOL))completion;
- (void)loginWithToken:(NSString *)token completion:(void (^)(BOOL))completion;
- (NSString *)loadTokenFromKeychain;
- (void)logout;

@end
