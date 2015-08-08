//
//  RegisterViewController.h
//  fakephonecall
//
//  Created by Philip Bale on 8/2/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actiivityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *backBUtton;

@end
