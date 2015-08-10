//
//  InAppPurchasesViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 8/8/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//
@import StoreKit;

#import "InAppPurchasesViewController.h"
#import "GeneralUtilities.h"
#import "FPCManager.h"

@interface InAppPurchasesViewController () <SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate>

@end

#define productIdentifiers @[@"fpc.calls.7", @"fpc.calls.15", @"fpc.calls.50"]

@implementation InAppPurchasesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![SKPaymentQueue canMakePayments])
    {
        [self.navigationController popViewControllerAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [GeneralUtilities makeAlertWithTitle:@"Error" message:@"Unable to make in-app purchases" viewController:self.navigationController];
        });
    }
}

- (IBAction)buyTier1Pressed:(id)sender {
    [self fireProductRequestForProductId:[productIdentifiers objectAtIndex:0]];
}

- (IBAction)buyTier2Pressed:(id)sender {
    [self fireProductRequestForProductId:[productIdentifiers objectAtIndex:1]];
}

- (IBAction)buyTier3Pressed:(id)sender {
    [self fireProductRequestForProductId:[productIdentifiers objectAtIndex:2]];
}

- (IBAction)testPurchaseAPI:(id)sender {
    [self.activityIndicatorView startAnimating];
    [[FPCManager sharedManager] processInAppPurchaseForProdId:[productIdentifiers objectAtIndex:0] completion:^(BOOL success) {
        if (success)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)fireProductRequestForProductId:(NSString *)productId
{
    [self.activityIndicatorView startAnimating];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSInteger count = [response.products count];
    if (count)
    {
        [self purchase:[response.products firstObject]];
    } else {
        [self.activityIndicatorView stopAnimating];
        NSLog(@"Failed to get valid product!");
    }
}

- (void)purchase:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    if (payment) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        [self.activityIndicatorView stopAnimating];
    }
}

//SKPaymentTransactionStatePurchasing,    0 // Transaction is being added to the server queue.
//SKPaymentTransactionStatePurchased,     1 // Transaction is in queue, user has been charged.  Client should complete the transaction.
//SKPaymentTransactionStateFailed,        2 // Transaction was cancelled or failed before being added to the server queue.
//SKPaymentTransactionStateRestored,
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"Handling transaction state: %ld", (long)transaction.transactionState);
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed with error %@", error);
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Completed");
    
    [[FPCManager sharedManager] processInAppPurchaseForProdId:transaction.payment.productIdentifier completion:^(BOOL success) {
        if (success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicatorView stopAnimating];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            NSLog(@"Failed to persist transaction");
            dispatch_async(dispatch_get_main_queue(), ^{
            [GeneralUtilities makeAlertWithTitle:@"Adding credits failed" message:@"If you paid and your credits do not show up, please contact us at support@logikcomputing.com and we will fix the issue!" viewController:self];
            });
        }
        
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Restore attempt");
    [self.activityIndicatorView stopAnimating];
    // Right now we aren't doing anything under the assumption that this won't happen.
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    [self.activityIndicatorView stopAnimating];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [GeneralUtilities makeAlertWithTitle:@"Purchase unsuccessful" message:@"Your purchase failed at some point. Please try again!" viewController:self];
    
    
}

@end
