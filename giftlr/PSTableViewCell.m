//
//  PSTableViewCell.m
//  giftlr
//
//  Created by Ke Huang on 3/18/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PSTableViewCell.h"

@implementation PSTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setPaymentInfo:(PaymentInfo *)paymentInfo {
    _paymentInfo = paymentInfo;
}

@end
