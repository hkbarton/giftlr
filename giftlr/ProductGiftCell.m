//
//  ProductGiftCell.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductGiftCell.h"
#import "UIImageView+AFNetworking.h"

@interface ProductGiftCell()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *hostImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostNameLabel;

@end

@implementation ProductGiftCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithProductGift:(ProductGift *)productGift {
    [self.posterImageView setImageWithURL:[NSURL URLWithString:productGift.imageURLs[0]]];
    self.nameLabel.text = productGift.name;
    self.priceLabel.text = [productGift.price stringValue];
}


@end
