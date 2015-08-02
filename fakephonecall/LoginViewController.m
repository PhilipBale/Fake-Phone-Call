//
//  LoginViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 7/30/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "LoginViewController.h"
#import "FPCManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginButtonPressed:(id)sender {
    [self.activityIndicator startAnimating];
    [self setButtonsEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [[FPCManager sharedManager] loginOrRegisterWithEmail:self.emailTextField.text password:self.passwordTextField.text name:@"nil" completion:^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.activityIndicator stopAnimating];
            [self setButtonsEnabled:YES];
        });
        
        if (success) [self performSegueWithIdentifier:@"login" sender:self];
    }];
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    self.loginButton.enabled = enabled;
    self.registerButton.enabled = enabled;
}

@end
