//
//  HomeViewController.h
//  fakephonecall
//
//  Created by Philip Bale on 7/31/15.
//  Copyright (c) 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AddressBook;
@import AddressBookUI;
#import "SWTableViewCell/SWTableViewCell.h"

@interface HomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, ABPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, SWTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *callsRemainingButton;

@end
