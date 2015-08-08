//
//  LoginViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 7/30/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "LoginViewController.h"
#import "FPCManager.h"
#import "Generalutilities.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *token = [[FPCManager sharedManager] loadTokenFromKeychain];
    if (token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self attemptAutoLoginWithToken:token];
        });
    }
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
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

- (void)attemptAutoLoginWithToken:(NSString *)token {
    [self.activityIndicator startAnimating];
    [self setButtonsEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [[FPCManager sharedManager] loginWithToken:token completion:^(BOOL success){
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.emailTextField || textField == self.passwordTextField)
    {
        [GeneralUtilities animateView:self.view up:YES delta:150 duration:.5];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.emailTextField || textField == self.passwordTextField)
    {
        [GeneralUtilities animateView:self.view up:NO delta:150 duration:.5];
    }
}

@end
