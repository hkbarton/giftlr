//
//  CashGiftCell.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "CashGiftCell.h"
#import "UIImageView+AFNetworking.h"

@interface CashGiftCell()

@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hostProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostNameLabel;


@end

@implementation CashGiftCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithCashGift:(CashGift *)cashGift {

    
    [self.posterImageView setImageWithURL:[NSURL URLWithString:cashGift.imageURLs[0]]];
    self.nameLabel.text = cashGift.name;

    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.amountLabel.text = [currencyFormat stringFromNumber:cashGift.amount];
    
    self.hostNameLabel.text = @""; // TODO get this from the gift's event
    
}

@end
