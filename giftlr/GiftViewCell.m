//
//  GiftViewCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "GiftViewCell.h"

@interface GiftViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *giftPicView;
@property (weak, nonatomic) IBOutlet UILabel *giftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *giftClaimImage;
@property (weak, nonatomic) IBOutlet UIImageView *giftPurchaseImage;

@end

@implementation GiftViewCell

- (void)awakeFromNib {
    // Initialization code
    self.giftPurchaseImage.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvent:(Event *)event {
    _event = event;
    
    if (event.isHostEvent) {
        self.giftPurchaseImage.hidden = YES;
        [self.giftClaimImage setImage:[UIImage imageNamed:@"Minus-25-black"]];
    } else {
        self.giftPurchaseImage.hidden = NO;
        [self.giftClaimImage setImage:[UIImage imageNamed:@"Hearts-26"]];
    }
}

@end
