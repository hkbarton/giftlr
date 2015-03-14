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

@interface EventProductGiftCell() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelDomain;
@property (weak, nonatomic) IBOutlet UIButton *btnClaim;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureReconginzer;

@end

@implementation EventProductGiftCell

- (void)awakeFromNib {
    self.imgProduct.layer.cornerRadius = 4.0f;
    self.imgProduct.clipsToBounds = YES;
    self.labelName.preferredMaxLayoutWidth = self.labelName.frame.size.width;
    self.controlView.hidden = YES;
    self.tapGestureReconginzer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideControlView)];
    self.tapGestureReconginzer.delegate = self;
    self.isControlMode = NO;
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

- (void) showControlView {
    if (!self.event.isHostEvent) {
        return;
    }
    
    self.containerViewLeadingContraint.constant = -80;
    self.containerViewTrailingConstraint.constant = 80;
    [self.containerView setNeedsLayout];
    self.isControlMode = YES;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        [self.containerView layoutIfNeeded];
        self.controlView.hidden = NO;
    } completion:^(BOOL finished) {
        [self.containerView addGestureRecognizer:self.tapGestureReconginzer];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }];
}

- (void) hideControlView {
    if (!self.event.isHostEvent) {
        return;
    }
    
    self.isControlMode = NO;
    [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    self.containerViewLeadingContraint.constant = 0;
    self.containerViewTrailingConstraint.constant = 0;
    [self.containerView setNeedsLayout];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        [self.containerView layoutIfNeeded];
        self.controlView.hidden = YES;
    } completion:^(BOOL finished) {
        [self.containerView removeGestureRecognizer:self.tapGestureReconginzer];
    }];
}

- (void)setProductGift:(ProductGift *)productGift {
    // Reset all the layout to default
    self.isControlMode = NO;
    [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    self.containerViewLeadingContraint.constant = 0;
    self.containerViewTrailingConstraint.constant = 0;
    [self.containerView setNeedsLayout];
    [self.containerView layoutIfNeeded];
    
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

#pragma mark - actions

- (IBAction)onDeleteGift:(id)sender {
    [self.delegate eventProductGiftCell:self didDeleteClicked:YES];
}

@end
