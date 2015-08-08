//
//  GeneralUtilities.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//
@import UIKit;

#import "GeneralUtilities.h"
#import "Realm/Realm.h"

@implementation GeneralUtilities

+ (NSMutableArray *) mutableArrayFromRealmResults:(RLMResults *)results
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:results.count];
    
    for (RLMObject *object in results) {
        [array addObject:object];
    }
    return array;
}

+ (void)animateView:(UIView *)view up:(BOOL)up delta:(CGFloat)delta duration:(NSTimeInterval)duration
{
    CGFloat normDelta = up ? -delta : delta;
    [UIView beginAnimations:@"animateView" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    view.frame = CGRectOffset(view.frame, 0, normDelta);
    [UIView commitAnimations];
}

+ (void)makeAlertWithTitle:(NSString *)title message:(NSString *)message viewController:(UIViewController *)viewController
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Dismiss"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    [alertController addAction:cancelAction];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
