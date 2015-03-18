//
//  ProductGiftCell.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductGiftCell.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"

@interface ProductGiftCell()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fromImageView;
@property (weak, nonatomic) IBOutlet UIImageView *toImageView;
@property (weak, nonatomic) IBOutlet UILabel *fromName;
@property (weak, nonatomic) IBOutlet UILabel *toName;

@end

@implementation ProductGiftCell

- (void)awakeFromNib {
    self.fromImageView.layer.cornerRadius = 25;
    self.fromImageView.clipsToBounds = YES;
    self.fromImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.fromImageView.layer.borderWidth = 1;

    self.toImageView.layer.cornerRadius = 25;
    self.toImageView.clipsToBounds = YES;
    self.toImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.toImageView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithProductGift:(ProductGift *)productGift {
    [self.posterImageView setImageWithURL:[NSURL URLWithString:productGift.imageURLs[0]]];
    self.nameLabel.text = productGift.name;

    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.priceLabel.text = [currencyFormat stringFromNumber:productGift.price];
    
    self.eventNameLabel.text = productGift.hostEvent.name;
    
    [User setUserProfileImage:self.fromImageView fbUserId:productGift.claimerFacebookUserID];
    [User setUserProfileImage:self.toImageView fbUserId:productGift.hostEvent.eventHostId];
    
    self.fromName.text = [self firstName:productGift.claimerName];
    self.toName.text = [self firstName:productGift.hostEvent.eventHostName];
}

- (NSString *) firstName:(NSString *)name {
    return [[name componentsSeparatedByString:@" "] objectAtIndex:0];
}


@end
