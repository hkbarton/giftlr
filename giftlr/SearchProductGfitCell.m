//
//  SearchProductGfitCell.m
//  giftlr
//
//  Created by Ke Huang on 3/24/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SearchProductGfitCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+giftlr.h"
#import "ProductHTMLParser.h"
#import "User.h"

@interface SearchProductGfitCell()

@property (weak, nonatomic) IBOutlet UIView *productContainerView;
@property (weak, nonatomic) IBOutlet UILabel *claimedByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelDomain;

@property (weak, nonatomic) IBOutlet UIView *eventContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *eventProfilePicView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIView *TimeContainerView;
@property (weak, nonatomic) IBOutlet UILabel *eventMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDayLabel;

@end

@implementation SearchProductGfitCell

- (void)awakeFromNib {
    self.imgProduct.layer.cornerRadius = 4.0f;
    self.imgProduct.clipsToBounds = YES;
    self.labelName.preferredMaxLayoutWidth = self.labelName.frame.size.width;
    self.claimedByLabel.hidden = YES;
    self.claimedByLabel.textColor = [UIColor hotPinkColor];
    self.contentView.backgroundColor = [UIColor lightGreyBackgroundColor];
    
    self.TimeContainerView.layer.cornerRadius = 3;
    self.TimeContainerView.clipsToBounds = YES;
    self.TimeContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.TimeContainerView.layer.borderWidth = 2.5;

    self.productContainerView.clipsToBounds = YES;
    self.eventContainerView.clipsToBounds = YES;
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)drawRoundCorner {
    UIBezierPath *pcMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.productContainerView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(3.0, 3.0)];
    CAShapeLayer *pcMaskLayer = [[CAShapeLayer alloc] init];
    pcMaskLayer.frame = self.productContainerView.bounds;
    pcMaskLayer.path  = pcMaskPath.CGPath;
    self.productContainerView.layer.mask = pcMaskLayer;
    
    UIBezierPath *ecMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.eventContainerView.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(3.0, 3.0)];
    CAShapeLayer *ecMaskLayer = [[CAShapeLayer alloc] init];
    ecMaskLayer.frame = self.eventContainerView.bounds;
    ecMaskLayer.path  = ecMaskPath.CGPath;
    self.eventContainerView.layer.mask = ecMaskLayer;
}

- (void)layoutSubviews {
    self.labelName.preferredMaxLayoutWidth = self.labelName.frame.size.width;
    [self drawRoundCorner];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setProductGift:(ProductGift *)productGift {
    _productGift = productGift;

    [self.imgProduct setImageWithURL:[NSURL URLWithString:productGift.imageURLs[0]]];
    self.labelName.text = productGift.name;
    [self.labelName sizeToFit];
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.labelPrice.text = [currencyFormat stringFromNumber:productGift.price];
    NSMutableString *source = [NSMutableString stringWithString:@"From: "];
    [source appendString:[ProductHTMLParser getDomainFromURL:[NSURL URLWithString:productGift.productURL]]];
    self.labelDomain.text = source;
    if ([productGift.status isEqualToString:ProductGiftStatusClaimed]) {
        if (self.productGift.claimerName != nil) {
            self.claimedByLabel.hidden = NO;
            NSString *claimerName = productGift.claimerName;
            if ([self.productGift.claimerFacebookUserID isEqualToString:[User currentUser].fbUserId]) {
                claimerName = @"me";
            }
            self.claimedByLabel.text = [NSString stringWithFormat:@"Claimed by %@", claimerName];
        }
    }
    if ([productGift.status isEqualToString:ProductGiftBought]) {
        if (self.productGift.claimerName != nil) {
            self.claimedByLabel.hidden = NO;
            if ([self.productGift.claimerFacebookUserID isEqualToString:[User currentUser].fbUserId]) {
                self.claimedByLabel.text = @"Purchased by me";
            } else {
                self.claimedByLabel.text = [NSString stringWithFormat:@"Claimed by %@", self.productGift.claimerName];
            }
        }
    }
    
    self.eventNameLabel.text = productGift.hostEvent.name;
    self.eventMonthLabel.text = productGift.hostEvent.startTimeMonth;
    self.eventDayLabel.text = productGift.hostEvent.startTimeDay;
    [self.eventProfilePicView setImage:[UIImage imageNamed:productGift.hostEvent.defaultEventProfileImage]];
}

@end
