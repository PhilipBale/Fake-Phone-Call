//
//  HTTPManager.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "HTTPManager.h" 
#import "AFNetworkActivityIndicatorManager.h"
#include "TargetConditionals.h"

#if TARGET_IPHONE_SIMULATOR
#define BASE_API_URL @"http:localhost:3001"
#else
#define BASE_API_URL @"http://www.logikapps.com"
#endif

#define API_VERSION @"1"
#define API_PATH(PATH) (BASE_API_URL @"/fake_phone_call/api/v" API_VERSION @"/" #PATH)

#define kAPIAttempts 5
#define kAPIAttemptDelay 0.25

NSString * const kApiLoginOrRegisterPath = API_PATH(login_or_register_user);
NSString * const kApiMakeCallPath = API_PATH(make_call);

@implementation HTTPManager

- (id)initWithBaseURLString:(NSString *)url
{
    self = [super initWithBaseURL: [NSURL URLWithString:url]];
    if(!self)
        return nil;
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    NSLog(@"Using base URL: %@", BASE_API_URL);
    return self;
    
}

- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self GET:URLString parameters:parameters success:success failure:failure attemptsLeft:kAPIAttempts];
}

- (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure attemptsLeft:(NSInteger)attemptsLeft
{
    [super GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL trueSuccess = [self wasSuccessfulGet:responseObject];
        if (success && trueSuccess)
        {
            success(responseObject);
        }
        else if (!trueSuccess)
        {
            if (failure)
            {
                NSLog(@"NOTICE: Successful HTTP GET but incorrect status code match");
                failure(nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (attemptsLeft)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAPIAttemptDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self GET:URLString parameters:parameters success:success failure:failure attemptsLeft:attemptsLeft - 1];
            });
        } else if (failure)
        {
            NSLog(@"HTTP MANAGER FINISHED FAILING GET AFTER %d attempts with %f delays inbetween", kAPIAttempts, kAPIAttemptDelay);
            failure(error);
        }
    }];
}
- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self POST:URLString parameters:parameters success:success failure:failure attemptsLeft:kAPIAttempts];
}

- (void)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure attemptsLeft:(NSInteger)attemptsLeft
{
    [super POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL trueSuccess = [self wasSuccessfulPost:responseObject];
        if (success && trueSuccess)
        {
            success(responseObject);
        }
        else if (!trueSuccess)
        {
            if (failure)
            {
                NSLog(@"NOTICE: Successful HTTP POST but incorrect status code match");
                failure(nil);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (attemptsLeft)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAPIAttemptDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self POST:URLString parameters:parameters success:success failure:failure attemptsLeft:attemptsLeft - 1];
            });
        } else if (failure)
        {
            NSLog(@"HTTP MANAGER FINISHED FAILING POST AFTER %d attempts with %f delays inbetween", kAPIAttempts, kAPIAttemptDelay);
            failure(error);
        }
    }];
}

- (BOOL)wasSuccessfulGet:(id)responseObject
{
    NSDictionary *responseDict = responseObject;
    return [responseDict[@"status"] isEqualToString:@"ok"];
}

- (BOOL)wasSuccessfulPost:(id)responseObject
{
    NSDictionary *responseDict = responseObject;
    return [responseDict[@"status"] isEqualToString:@"created"];
}

- (void)setRequestHeadersForAPIToken:(NSString *)apiToken
{
    [self.requestSerializer setValue:apiToken forHTTPHeaderField:@"token"];
}

#pragma mark - Singleton Methods

+ (HTTPManager *)sharedManager
{
    static dispatch_once_t pred;
    static HTTPManager *_sharedManager = nil;
    
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] initWithBaseURLString: BASE_API_URL]; });
    return _sharedManager;
}


@end
