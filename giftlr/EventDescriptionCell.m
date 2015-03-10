//
//  EventDescriptionCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventDescriptionCell.h"

@implementation EventDescriptionCell

- (void)awakeFromNib {
    // Initialization code
    UIColor *lightGrey = [UIColor  colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    self.backgroundColor = lightGrey;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
