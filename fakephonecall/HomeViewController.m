//
//  HomeViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 7/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "HomeViewController.h"


@interface HomeViewController ()
@property (nonatomic, strong) NSArray *cachedNumberArray;
@property (nonatomic, strong) NSString *cachedName;
@property (nonatomic, strong) UIActionSheet *cachedActionSheet;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view.
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    //UIView *navBottomBorder = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    //[navBottomBorder removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    cell.textLabel.text = @"Contact Name";
    cell.detailTextLabel.text = @"Phone Number";
    return cell;
    
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (IBAction)shopButtonPressed:(id)sender {
}

- (IBAction)callsRemainingButtonPressed:(id)sender {
}

- (IBAction)settingsButtonPressed:(id)sender {
}

- (IBAction)addContactButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Contact from"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Custom Entry", @"Phone Contacts",nil];
    
    [actionSheet showInView:self.view];
}

- (void)saveContactWithName:(NSString *)name number:(NSString*)number
{
    NSLog(@"Saving contact with name: %@, number: %@", name, number);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.cachedActionSheet)
    {
        NSString *number = [self.cachedNumberArray objectAtIndex:buttonIndex - 1];
        [self saveContactWithName:self.cachedName number:number];
        return;
    }
    switch (buttonIndex) {
        case 0:
            NSLog(@"Custom entry selected");
            break;
        case 1:
            NSLog(@"Contacts selected");
            [self requestAddressBookPermissionAndShowPicker:YES];
            break;
        default:
            break;
    }
}

- (void)requestAddressBookPermissionAndShowPicker:(BOOL)showPicker
{
    BOOL authorized = ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized;
    if (!authorized)
    {
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (granted && showPicker) {
                [self requestAddressBookPermissionAndShowPicker:YES];
            } else if (!granted)
            {
                NSLog(@"No contact book access");
                [self makeAlertWithTitle:@"No Address Book Access" message:@"Please allow access in your device's system settings menu"];
            }
        });
    } else {
        NSLog(@"Accessing contact book");
        ABPeoplePickerNavigationController *personPicker = [ABPeoplePickerNavigationController new];
        
        personPicker.peoplePickerDelegate = self;
        [self presentViewController:personPicker animated:YES completion:nil];
    }
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phoneNumbers) {
        NSMutableArray *allNumbers = [[NSMutableArray alloc] init];
        NSMutableArray *actionSheetNumbersArray = [[NSMutableArray alloc] init];
        
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            CFStringRef phoneNumberLabelRef = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
            NSString *phoneNumber = [NSString stringWithFormat:@"%@", phoneNumberRef];
            NSString *phoneNumberLabel  = [[[NSString stringWithFormat:@"%@: ", phoneNumberLabelRef] stringByReplacingOccurrencesOfString:@"_$!<" withString:@""] stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
            
            [allNumbers addObject:phoneNumber];
            [actionSheetNumbersArray addObject:[NSString stringWithFormat:@"%@%@", phoneNumberLabel, phoneNumber]];
            NSLog(@"Phone number selected:%@", [actionSheetNumbersArray lastObject]);
            
            CFRelease(phoneNumberLabelRef);
            CFRelease(phoneNumberRef);
        }
        CFRelease(phoneNumbers);
        
        if (numberOfPhoneNumbers > 1)
        {
            self.cachedNumberArray = allNumbers;
            self.cachedName = fullName;
            UIActionSheet *numberSelectSheet = [[UIActionSheet alloc] initWithTitle:@"Select Phone Number" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
            for (NSString *numberLabel in actionSheetNumbersArray)
            {
                [numberSelectSheet addButtonWithTitle:numberLabel];
            }
            
            self.cachedActionSheet = numberSelectSheet;
            [numberSelectSheet showInView:self.view];
        }
        else
        {
            [self saveContactWithName:fullName number:[allNumbers lastObject]];
        }
    } else {
        [self makeAlertWithTitle:@"Error" message:@"No phone number for contact"];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    //[self dismissViewControllerAnimated:YES completion:nil];
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
