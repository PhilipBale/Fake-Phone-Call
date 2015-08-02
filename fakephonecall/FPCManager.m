//
//  SharedDataManager.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "FPCManager.h"
#import "HTTPManager.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>

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
    NSDictionary *placeCallParams = @{@"call":@{@"number": number, @"when":[NSNumber numberWithInteger:when]}};
    [[HTTPManager sharedManager] POST:kApiPlaceCallPath parameters:placeCallParams success:^(id responseObject) {
        [self assignCurrentUserWithUserDictionary:[responseObject objectForKey:@"user"]];
        
        if (completion) completion(YES);
    } failure:^(NSError *error) {
        if (completion) completion(NO);
    }];
}

- (void)logout
{
    self.currentUser = nil;
    [self saveTokenToKeychain:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabBarController = (UITabBarController *)appDelegate.window.rootViewController;
    [tabBarController dismissViewControllerAnimated:true completion:nil];

}

- (void)loginOrRegisterWithEmail:(NSString *)email password:(NSString *)password name:(NSString *)name completion:(void (^)(BOOL))completion
{
    NSDictionary *loginOrRegisterParams = @{@"user":@{ @"email": email, @"password": password, @"name":name}};
    [[HTTPManager sharedManager] GET:kApiLoginOrRegisterPath parameters:loginOrRegisterParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         [self assignCurrentUserWithUserDictionary:response];
         
         if (completion) completion(YES);
     } failure:^(NSError *error) {
         if (completion) completion(NO);
     }];
}

- (void)loginWithToken:(NSString *)token completion:(void (^)(BOOL))completion
{
    NSDictionary *loginWithTokenParams = @{@"user":@{ @"token": token}};
    [[HTTPManager sharedManager] GET:kApiLoginWithTokenPath parameters:loginWithTokenParams success:^(NSDictionary *responseObject)
     {
         NSDictionary *response = [responseObject objectForKey:@"user"];
         [self assignCurrentUserWithUserDictionary:response];
         
         if (completion) completion(YES);
     } failure:^(NSError *error) {
         if (completion) completion(NO);
     }];
}

- (void)assignCurrentUserWithUserDictionary:(NSDictionary *) userDictionary
{
    FPCUser *user = [[FPCUser alloc] init];
    user.userId = [[userDictionary objectForKey:@"id"] integerValue];
    user.email = [userDictionary objectForKey:@"email"];;
    user.token = [userDictionary objectForKey:@"token"];
    user.name = [userDictionary objectForKey:@"name"];;
    user.callsPlaced = [[userDictionary objectForKey:@"calls_placed"] integerValue];
    user.callsRemaining = [[userDictionary objectForKey:@"calls_remaining"] integerValue];
    user.admin = [[userDictionary objectForKey:@"admin"] boolValue];
    
    self.currentUser = (FPCUser *)[self expressDefaultRealmWrite:user];
    [[HTTPManager sharedManager] setRequestHeadersForAPIToken:self.currentUser.token];
    [self saveTokenToKeychain:self.currentUser.token];

}

- (void)saveTokenToKeychain:(NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"token"];
    [defaults synchronize];
}

- (NSString *)loadTokenFromKeychain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"token"];
}

- (RLMObject *)expressDefaultRealmWrite:(RLMObject *)object
{
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    RLMObject *returnObj = [object.class createOrUpdateInRealm:[RLMRealm defaultRealm] withValue:object];
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
    return returnObj;
}

@end
