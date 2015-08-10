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
#import "FPCContact.h"
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
    if (self.currentUser.callsRemaining == 0) {
        if (completion) completion(NO);
        return;
    }
    
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

- (void)saveContactWithName:(NSString *)name number:(NSString*)number completion:(void (^)(BOOL))completion

{
    NSLog(@"Saving contact with name: %@, number: %@", name, number);
    FPCContact *contact = [[FPCContact alloc] init];
    contact.name = name;
    contact.number = number;
    NSString *idHash = [NSString stringWithFormat: @"%@ %@", name, number];
    contact.contactId = [idHash hash];
    
    [[RLMRealm defaultRealm] beginWriteTransaction];
    {
        [FPCContact createOrUpdateInDefaultRealmWithValue:contact];
    }
    [[RLMRealm defaultRealm] commitWriteTransaction];
    if (completion) completion(YES);
}

- (void)processInAppPurchaseForProdId:(NSString *)prodId completion:(void (^)(BOOL))completion
{
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:0];
    
    if (false) {
        receiptString = [FPCManager sendboxReceipt];
    }
    
    if (!receiptString) {
        if (completion) completion(NO);
        return;
    }
    
    NSDictionary *purchaseParams = @{@"purchase":@{@"prod_id": prodId, @"receipt_data": receiptString}};
  
    [[HTTPManager sharedManager] POST:kApiPurchasePath parameters:purchaseParams success:^(id responseObject) {
        [self assignCurrentUserWithUserDictionary:[responseObject objectForKey:@"user"]];
        if (completion) completion(YES);
    } failure:^(NSError *error) {
        if (completion) completion(NO);
    }];
}

+ (NSString *)sendboxReceipt
{
    return @"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";
}

@end
