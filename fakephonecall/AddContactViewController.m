//
//  AddContactViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 8/8/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "AddContactViewController.h"
#import "GeneralUtilities.h"
#import "FPCManager.h"

@interface AddContactViewController ()

@end

@implementation AddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundView.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)saveButtonPressed:(id)sender {
    if (self.nameTextField.text.length < 2)
    {
        [GeneralUtilities makeAlertWithTitle:@"Input Error" message:@"Please enter a valid name" viewController:self];
    } else if (self.numberTextField.text.length  < 10)
    {
        [GeneralUtilities makeAlertWithTitle:@"Input Error" message:@"Please enter a valid phone number" viewController:self];
    } else {
        [[FPCManager sharedManager] saveContactWithName:self.nameTextField.text number:self.numberTextField.text completion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    }
}

@end
