//
//  EventProductGiftCell.m
//  giftlr
//
//  Created by Ke Huang on 3/10/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventProductGiftCell.h"
#import "UIImageView+AFNetworking.h"
#import "ProductHTMLParser.h"

@interface EventProductGiftCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelDomain;
@property (weak, nonatomic) IBOutlet UIButton *btnClaim;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;

@end

@implementation EventProductGiftCell

- (void)awakeFromNib {
    self.imgProduct.layer.cornerRadius = 4.0f;
    self.imgProduct.clipsToBounds = YES;
    self.labelName.preferredMaxLayoutWidth = self.labelName.frame.size.width;
}

- (void)layoutSubviews {
    self.labelName.preferredMaxLayoutWidth = self.labelName.frame.size.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setEvent:(Event *)event {
    _event = event;
    if (event.isHostEvent) {
        self.btnBuy.hidden = YES;
        self.btnClaim.hidden = YES;
    } else {
        self.btnBuy.hidden = NO;
        self.btnClaim.hidden = NO;
    }
}

- (void)setProductGift:(ProductGift *)productGift {
    _productGift = productGift;
    [self.imgProduct setImageWithURL:[NSURL URLWithString:productGift.imageURLs[0]]];
    self.labelName.text = productGift.name;
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.labelPrice.text = [currencyFormat stringFromNumber:productGift.price];
    NSMutableString *source = [NSMutableString stringWithString:@"From: "];
    [source appendString:[ProductHTMLParser getDomainFromURL:[NSURL URLWithString:productGift.productURL]]];
    self.labelDomain.text = source;
    if ([productGift.status isEqualToString:ProductGiftStatusClaimed]) {
        [self.btnClaim setImage:[UIImage imageNamed:@"Hearts-26-pink"] forState:UIControlStateNormal];
    }
    if ([productGift.status isEqualToString:ProductGiftBought]) {
        [self.btnClaim setImage:[UIImage imageNamed:@"Hearts-26-pink"] forState:UIControlStateNormal];
        [self.btnBuy setImage:[UIImage imageNamed:@"Buy-24-pink"] forState:UIControlStateNormal];
    }
}

@end
