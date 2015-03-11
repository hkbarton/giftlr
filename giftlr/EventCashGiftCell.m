//
//  EventCashGiftCell.m
//  giftlr
//
//  Created by Ke Huang on 3/10/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventCashGiftCell.h"
#import "CashGift.h"

@interface EventCashGiftCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fulfilledLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation EventCashGiftCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCashGift:(CashGift *)cashGift {
    _cashGift = cashGift;

    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];

    self.nameLabel.text = cashGift.name;
    self.fulfilledLabel.text = @"?"; // TODO figure out the total fulfilled amount
    self.amountLabel.text = [currencyFormat stringFromNumber:cashGift.amount];
}

@end
