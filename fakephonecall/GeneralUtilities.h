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
+ (void)animateView:(UIView *)view up:(BOOL)up delta:(CGFloat)delta duration:(NSTimeInterval)duration;
+ (void)makeAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController;

@end
