//
//  AppDelegate.m
//  fakephonecall
//
//  Created by Philip Bale on 7/30/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "AppDelegate.h"
#import "RLMRealm.h"
#import "FPCManager.h"
#import "WormholeManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];
    
    [WormholeManager sharedManager];
    NSURL *realmDirectoy = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.logikcomputing.fakephonecall"];
    NSString *realmPath = [realmDirectoy.path stringByAppendingString:@"/db.realm"];
    
    [RLMRealm setDefaultRealmPath:realmPath];
    
    return YES;
}

-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply
{
    NSLog(@"Handling parent app request!");
    __block UIBackgroundTaskIdentifier watchKitHandler;
    watchKitHandler = [[UIApplication sharedApplication]
                       beginBackgroundTaskWithName:@"backgroundTask"
                       expirationHandler:^{
                           watchKitHandler = UIBackgroundTaskInvalid;
                       }];
    
    NSString *token = [[FPCManager sharedManager] loadTokenFromKeychain];
    BOOL curUser = [FPCManager sharedManager].currentUser != nil;
    
    if (!curUser) {
        if (token) {
            [[FPCManager sharedManager] loginWithToken:token completion:^(BOOL success){
                if (success)
                {
                    [[FPCManager sharedManager] placeCallToNumber:[userInfo objectForKey:@"number"] when:[[userInfo objectForKey:@"when"] integerValue] completion:^(BOOL success) {
                        [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"extensionCallPlaced" object:nil];
                    }];
                }
                else
                {
                    [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
                }
            }];
        }
        else
        {
            [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
        }
    }
    else
    {
        [[FPCManager sharedManager] placeCallToNumber:[userInfo objectForKey:@"number"] when:[[userInfo objectForKey:@"when"] integerValue] completion:^(BOOL success) {
            [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"extensionCallPlaced" object:nil];
        }];
    } 
    reply(nil);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
