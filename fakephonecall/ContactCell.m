//
//  ContactCell.m
//  fakephonecall
//
//  Created by Philip Bale on 8/1/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell

- (void)awakeFromNib {    self.leftUtilityButtons = [self leftButtons];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor redColor] title:@"Remove"];
    
    //    [leftUtilityButtons sw_addUtilityButtonWithColor:
    //     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
    //                                                title:@"Delete"];
    
    return leftUtilityButtons;
}

@end
