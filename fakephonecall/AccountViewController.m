//
//  AccountViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "AccountViewController.h"
#import "FPCManager.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonPressed:(id)sender {
    [[FPCManager sharedManager] logout];
}

@end
