//
//  RegisterViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "RegisterViewController.h"
#import "FPCManager.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        
    }
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validateFields
{
    if (self.nameTextField.text.length < 3)
    {
        [self makeAlertWithTitle:@"Invalid name" message:@"Please enter a valid name!"];
        return NO;
    }
    else if (![self validateEmail:self.emailTextField.text])
    {
        [self makeAlertWithTitle:@"Invalid email" message:@"Please enter a valid email address"];
        return NO;
    }
    else if (self.passwordTextField.text.length < 7)
    {
        [self makeAlertWithTitle:@"Password too short" message:@"Please make password at least 7 characters long"];
        return NO;
    }
    
    return YES;
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
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

@end
