//
//  CashGiftCell.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "CashGiftCell.h"

@interface CashGiftCell()

@property (weak, nonatomic) IBOutlet UIView *posterImageView;
@property (weak, nonatomic) IBOutlet UIView *hostImageView;
@property (weak, nonatomic) IBOutlet UIView *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIView *hostNameLabel;
@property (weak, nonatomic) IBOutlet UIView *totalLabel;
@property (weak, nonatomic) IBOutlet UIView *fulfilledLabel;
@property (weak, nonatomic) IBOutlet UIView *amountLabel;


@end

@implementation CashGiftCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
