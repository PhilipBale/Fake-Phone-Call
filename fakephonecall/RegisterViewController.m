//
//  RegisterViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "RegisterViewController.h"
#import "FPCManager.h"
#import "FPCUser.h"
#import "GeneralUtilities.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.nameTextField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)registerButtonPressed:(id)sender {
    if ([self validateFields])
    {
        [self.actiivityIndicator startAnimating];
        [self setButtonsEnabled:NO];
        
        __weak typeof(self) weakSelf = self;
        [[FPCManager sharedManager] loginOrRegisterWithEmail:self.emailTextField.text password:self.passwordTextField.text name:self.nameTextField.text completion:^(BOOL success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.actiivityIndicator stopAnimating];
                [self setButtonsEnabled:YES];
            });
            
            if (success) [self performSegueWithIdentifier:@"login" sender:self];
        }];
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{ 
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)validateFields
{
    
    NSInteger userCount = [FPCUser allObjects].count;
    if (userCount >= 3)
    {
        [self makeAlertWithTitle:@"Too Many Users" message:@"We're sorry, but you've already registered 3 users and are at the limit. Please use an existing account"];
        return NO;
    }
    else if (self.nameTextField.text.length < 3)
    {
        [self makeAlertWithTitle:@"Invalid name" message:@"Please enter a valid name!"];
        return NO;
    }
    else if (![self validateEmail:self.emailTextField.text])
    {
        [self makeAlertWithTitle:@"Invalid email" message:@"Please enter a valid email address"];
        return NO;
    }
    else if (self.passwordTextField.text.length < 6)
    {
        [self makeAlertWithTitle:@"Password too short" message:@"Please make password at least 6 characters long"];
        return NO;
    }
    
    
    
    
    return YES;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (void)makeAlertWithTitle:(NSString *)title message:(NSString *)message
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
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    self.registerButton.enabled = enabled;
    self.backBUtton.enabled = enabled;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.nameTextField || textField == self.emailTextField || textField == self.passwordTextField)
    {
        [GeneralUtilities animateView:self.view up:YES delta:150 duration:.5];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameTextField || textField == self.emailTextField || textField == self.passwordTextField)
    {
        [GeneralUtilities animateView:self.view up:NO delta:150 duration:.5];
    }
}

@end
