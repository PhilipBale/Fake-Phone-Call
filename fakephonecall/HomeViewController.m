//
//  HomeViewController.m
//  fakephonecall
//
//  Created by Philip Bale on 7/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import "HomeViewController.h"
#import "Realm/Realm.h"
#import "FPCUser.h"
#import "FPCContact.h"
#import "ContactCell.h"
#import "GeneralUtilities.h"
#import "FPCManager.h"
#import "WormholeManager.h"

@interface HomeViewController ()

@property (nonatomic, strong) NSArray *cachedNumberArray;
@property (nonatomic, strong) NSArray *cachedLabelArray;

@property (nonatomic, strong) NSString *cachedName;
@property (nonatomic, strong) NSString *toCallCachedNumber;

@property (nonatomic, strong) UIActionSheet *cachedActionSheet;
@property (nonatomic, strong) UIActionSheet *callActionSheet;

@property NSMutableArray* contacts;

@end

#define callOptions @[@0, @30, @60, @300, @600]

@implementation HomeViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view.
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    //UIView *navBottomBorder = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    //[navBottomBorder removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCallsRemaining) name:@"extensionCallPlaced" object:nil];
    
    [self updateContacts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCallsRemaining];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateContacts];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = (ContactCell *)[tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    FPCContact *contact = [self.contacts objectAtIndex:indexPath.row];
    cell.delegate = self;
    cell.textLabel.text = contact.name;
    cell.detailTextLabel.text = contact.number;
    cell.contactId = contact.contactId;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FPCContact *contact = [self.contacts objectAtIndex:indexPath.row];
    NSString *subject = [NSString stringWithFormat:@"Call %@", [self shortenedNameForContact:contact] ];
    self.callActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:[NSString stringWithFormat:@"%@ now", subject],[NSString stringWithFormat:@"%@ in 30 sec", subject], [NSString stringWithFormat:@"%@ in 1 min", subject], [NSString stringWithFormat:@"%@ in 5 min", subject], [NSString stringWithFormat:@"%@ in 10 min", subject],nil];
    self.toCallCachedNumber = contact.number;
    [self.callActionSheet showInView:self.view];
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
    [[FPCManager sharedManager] saveContactWithName:name number:number completion:^(BOOL success) {
        [self updateContacts];
        [self.tableView reloadData];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.cachedActionSheet)
    {
        NSString *number = [self.cachedNumberArray objectAtIndex:buttonIndex - 1];
        NSString *label = [self.cachedLabelArray objectAtIndex:buttonIndex - 1];
        if (label.length > 0 && ![label isEqualToString:@"()"])
        {
            self.cachedName = [NSString stringWithFormat:@"%@ %@", self.cachedName, label];
        }
        
        [self saveContactWithName:self.cachedName number:number];
        return;
    } else if (actionSheet == self.callActionSheet)
    {
        if (buttonIndex >= [callOptions count]) return;
        NSInteger when = [[callOptions objectAtIndex:buttonIndex] integerValue];
        NSLog(@"Placing call in %li secs", (long) when);
        if ([FPCManager sharedManager].currentUser.callsRemaining == 0) {
            [GeneralUtilities makeAlertWithTitle:@"No Credits Remaining" message:@"Please purchase more call credit to continue!" viewController:self];
            return;
        }
        [[FPCManager sharedManager] placeCallToNumber:self.toCallCachedNumber when:when completion:^(BOOL completion){
            __weak typeof(self) weakSelf = self;
            [weakSelf callPlacedSuccess:completion];
        }];
        
        return;
    }
    switch (buttonIndex) {
        case 0:
            NSLog(@"Custom entry selected");
            [self performSegueWithIdentifier:@"customContact" sender:self];
            break;
        case 1:
            NSLog(@"Contacts selected");
            [self requestAddressBookPermissionAndShowPicker:YES];
            break;
        default:
            break;
    }
}

- (void)callPlacedSuccess:(BOOL)success
{
    if (success) {
        [self updateCallsRemaining];
        NSLog(@"Call placed");
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
                [GeneralUtilities makeAlertWithTitle:@"No Address Book Access" message:@"Please allow access in your device's system settings menu" viewController:self];
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
    NSString *fullName = [[NSString stringWithFormat:@"%@, %@", lastName, firstName] stringByReplacingOccurrencesOfString:@"(null), " withString:@""];
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phoneNumbers) {
        NSMutableArray *allNumbers = [[NSMutableArray alloc] init];
        NSMutableArray *allLabels = [[NSMutableArray alloc] init];
        NSMutableArray *actionSheetNumbersArray = [[NSMutableArray alloc] init];
        
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            CFStringRef phoneNumberLabelRef = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
            NSString *phoneNumber = [NSString stringWithFormat:@"%@", phoneNumberRef];
            NSString *phoneNumberLabel  = [[[NSString stringWithFormat:@"%@: ", phoneNumberLabelRef] stringByReplacingOccurrencesOfString:@"_$!<" withString:@""] stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
            NSString *phoneNumberLabelFinal  = [[[NSString stringWithFormat:@"(%@)", phoneNumberLabelRef] stringByReplacingOccurrencesOfString:@"_$!<" withString:@""] stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
            
            [allNumbers addObject:phoneNumber];
            [allLabels addObject:phoneNumberLabelFinal];
            [actionSheetNumbersArray addObject:[NSString stringWithFormat:@"%@%@", phoneNumberLabel, phoneNumber]];
            NSLog(@"Phone number selected:%@", [actionSheetNumbersArray lastObject]);
            
            CFRelease(phoneNumberLabelRef);
            CFRelease(phoneNumberRef);
        }
        CFRelease(phoneNumbers);
        
        if (numberOfPhoneNumbers > 1)
        {
            self.cachedNumberArray = allNumbers;
            self.cachedLabelArray = allLabels;
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
        [GeneralUtilities makeAlertWithTitle:@"Error" message:@"No phone number for contact" viewController:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)swipeableTableViewCell:(ContactCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSLog(@"Removing %li", (long)cell.contactId);
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            FPCContact *toRemove = [self.contacts objectAtIndex:cellIndexPath.item];
            
            [[RLMRealm defaultRealm] beginWriteTransaction];
            {
                [[RLMRealm defaultRealm] deleteObject:toRemove];
            }
            [[RLMRealm defaultRealm] commitWriteTransaction];
            [self.contacts removeObjectAtIndex:cellIndexPath.item];
            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
    }
}

- (NSString *)shortenedNameForContact:(FPCContact *)contact
{
    NSArray *split = [contact.name componentsSeparatedByString:@" "];
    NSString *shortened;
    if (split.count == 3)
    {
        return [split objectAtIndex:1];
    }
    else if (split.count == 2)
    {
        if ([((NSString *)[split objectAtIndex:1]) containsString:@"("])
        {
            shortened = [NSString stringWithFormat:@"%@", [split objectAtIndex:0]];
        }
        else
        {
            shortened =  [NSString stringWithFormat:@"%@", [split objectAtIndex:1]];
        }
    }
    else
    {
        shortened =  [split objectAtIndex:0];
    }
    
    return [shortened stringByReplacingOccurrencesOfString:@"," withString:@""];
    
}

- (void)updateCallsRemaining
{
    NSInteger callsRemaining = [FPCManager sharedManager].currentUser.callsRemaining;
    [self.callsRemainingButton setTitle:[NSString stringWithFormat:@"%li calls remaining",(long) callsRemaining] forState:UIControlStateNormal];
    [self.callsRemainingButton setBackgroundColor: callsRemaining > 0 ? [UIColor colorWithRed:73.0/255 green:161.0/255 blue:61.0/255 alpha:1] : [UIColor redColor]];
}

- (void)updateContacts
{
    self.contacts = [GeneralUtilities mutableArrayFromRealmResults:[[FPCContact allObjects] sortedResultsUsingProperty:@"name" ascending:YES]];
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

@end
