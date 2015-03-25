//
//  PSTableViewCell.m
//  giftlr
//
//  Created by Ke Huang on 3/18/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PSTableViewCell.h"
#import "PTKCardType.h"

@interface PSTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageCardType;
@property (weak, nonatomic) IBOutlet UILabel *labelLast4;

@end

@implementation PSTableViewCell

- (void)awakeFromNib {
    UIView *selectedBgView = [[UIView alloc] init];
    selectedBgView.backgroundColor = [UIColor clearColor];
    [self setSelectedBackgroundView:selectedBgView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setPaymentInfo:(PaymentInfo *)paymentInfo {
    _paymentInfo = paymentInfo;
    NSString *numberFormatStr = @"**** **** **** %@";
    switch (paymentInfo.cardType) {
        case PTKCardTypeVisa:
            self.imageCardType.image = [UIImage imageNamed:@"cc-visa"];
            break;
        case PTKCardTypeAmex:
            self.imageCardType.image = [UIImage imageNamed:@"cc-amex"];
            numberFormatStr = @"**** ****** *%@";
            break;
        case PTKCardTypeMasterCard:
            self.imageCardType.image = [UIImage imageNamed:@"cc-master"];
            break;
        case PTKCardTypeJCB:
            self.imageCardType.image = [UIImage imageNamed:@"cc-jcb"];
            break;
        default:
            self.imageCardType.image = [UIImage imageNamed:@"cc-unknown"];
            break;
    }
    self.labelLast4.text = [NSString stringWithFormat:numberFormatStr, paymentInfo.last4];
}

@end
