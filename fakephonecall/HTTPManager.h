//
//  HTTPManager.h
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

extern NSString * const kApiLoginOrRegisterPath;
extern NSString * const kApiPlaceCallPath;
extern NSString * const kApiLoginWithTokenPath;

@interface HTTPManager : AFHTTPRequestOperationManager

+ (HTTPManager *)sharedManager;
- (BOOL)wasSuccessfulGet:(id)responseObject;
- (BOOL)wasSuccessfulPost:(id)responseObject;
- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)setRequestHeadersForAPIToken:(NSString *)apiToken;

@end
