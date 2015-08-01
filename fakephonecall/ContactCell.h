//
//  ContactCell.h
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell/SWTableViewCell.h"

@interface ContactCell : SWTableViewCell<SWTableViewCellDelegate>

@property (nonatomic) NSInteger contactId;

@end
