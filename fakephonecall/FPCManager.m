//
//  SharedDataManager.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "FPCManager.h"
#import "HTTPManager.h"

@implementation FPCManager

+ (FPCManager *)sharedManager
{
    static dispatch_once_t pred;
    static FPCManager *_sharedManager = nil;
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] init]; });
    return _sharedManager;
}

- (void) placeCallToNumber:(NSString *)number when:(NSInteger)when completion:(void (^)(BOOL))completion
{
    if (completion) {
        completion(YES);
    }
}

- (void)loginOrRegisterWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name completion:(void (^)(BOOL))completion
{
    NSDictionary *loginOrRegisterParams = @{@"user":@{ @"email": email, @"password": password, @"name":name}};
    [[HTTPManager sharedManager] GET:kApiLoginOrRegisterPath parameters:loginOrRegisterParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         FPCUser *user = [[FPCUser alloc] init];
         user.userId = [[response objectForKey:@"id"] integerValue];
         user.email = [response objectForKey:@"email"];;
         user.token = [response objectForKey:@"token"];
         user.name = [response objectForKey:@"name"];;
         user.callsPlaced = [[response objectForKey:@"calls_placed"] integerValue];
         user.callsRemaining = [[response objectForKey:@"calls_remaining"] integerValue];
         user.admin = [[response objectForKey:@"admin"] boolValue];
         
         self.currentUser = (FPCUser *)[self expressDefaultRealmWrite:user];
         [[HTTPManager sharedManager] setRequestHeadersForAPIToken:self.currentUser.token];
         if (completion) completion(YES);
     } failure:^(NSError *error) {
         if (completion) completion(NO);
     }];
}

- (RLMObject *)expressDefaultRealmWrite:(RLMObject *)object
{
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    RLMObject *returnObj = [object.class createOrUpdateInRealm:[RLMRealm defaultRealm] withValue:object];
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
    return returnObj;
}

@end
