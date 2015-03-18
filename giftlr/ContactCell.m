//
//  ContactCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/17/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ContactCell.h"

@interface ContactCell ()

@property (weak, nonatomic) IBOutlet UIImageView *contactImageView;
@property (weak, nonatomic) IBOutlet UILabel *contactnameLabel;

@end

@implementation ContactCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContact:(User *)contact {
    _contact = contact;
    for (UIView *view in self.contactImageView.subviews) {
        [view removeFromSuperview];
    }
    [contact setUserProfileImage:self.contactImageView];
    self.contactnameLabel.text = contact.name;
}

@end
