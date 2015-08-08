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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    FPCUser *currentUser = [[FPCManager sharedManager] currentUser];
    self.nameLabel.text = [NSString stringWithFormat:@"Name: %@", currentUser.name];
    self.emailLabel.text = [NSString stringWithFormat:@"Email: %@", currentUser.email];
    
    [self setupStringForLabel:self.nameLabel contentStart:6];
    [self setupStringForLabel:self.emailLabel contentStart:7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButtonPressed:(id)sender {
    [[FPCManager sharedManager] logout];
}

- (void)setupStringForLabel:(UILabel *)label contentStart:(NSInteger)contentStart
{
    NSMutableAttributedString* attrStr =  [label.attributedText mutableCopy];
    // for those calls we don't specify a range so it affects the whole string
    
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, contentStart)];
    [label setAttributedText:attrStr];
}

@end
