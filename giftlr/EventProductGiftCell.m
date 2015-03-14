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

@property (weak, nonatomic) IBOutlet UILabel *claimedByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelDomain;
@property (weak, nonatomic) IBOutlet UIButton *btnClaim;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;
@property (weak, nonatomic) IBOutlet UIButton *btnUnclaim;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *buyStatus;
@property (weak, nonatomic) IBOutlet UIButton *claimStatus;

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
    self.claimedByLabel.hidden = YES;
    self.buyStatus.hidden = YES;
    self.claimStatus.hidden = YES;
    [self hideAllControlButtons];
}

- (void)layoutSubviews {
    self.labelName.preferredMaxLayoutWidth = self.labelName.frame.size.width;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setEvent:(Event *)event {
    _event = event;
}

- (void)hideAllControlButtons {
    self.btnBuy.hidden = YES;
    self.btnClaim.hidden = YES;
    self.btnDelete.hidden = YES;
    self.btnUnclaim.hidden = YES;
}

- (void)showControlView {
    NSInteger newConstraint;
    [self hideAllControlButtons];
    if (self.event.isHostEvent) {
        newConstraint = -80;
        self.btnDelete.hidden = NO;
    } else {
        if ([self.productGift.status isEqualToString:ProductGiftStatusUnclaimed]){
            newConstraint = -80;
            self.btnClaim.hidden = NO;
        } else if ([self.productGift.status isEqualToString:ProductGiftStatusClaimed]){
            newConstraint = -160;
            self.btnUnclaim.hidden = NO;
            self.btnBuy.hidden = NO;
        } else {
            return;
        }
    }
    
    self.containerViewLeadingContraint.constant = newConstraint;
    self.containerViewTrailingConstraint.constant = 0 - newConstraint;
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

- (void)hideControlView {
    self.isControlMode = NO;
    [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    self.containerViewLeadingContraint.constant = 0;
    self.containerViewTrailingConstraint.constant = 0;
    [self.containerView setNeedsLayout];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        [self.containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.containerView removeGestureRecognizer:self.tapGestureReconginzer];
        self.controlView.hidden = YES;
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
    [self.labelName sizeToFit];
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.labelPrice.text = [currencyFormat stringFromNumber:productGift.price];
    NSMutableString *source = [NSMutableString stringWithString:@"From: "];
    [source appendString:[ProductHTMLParser getDomainFromURL:[NSURL URLWithString:productGift.productURL]]];
    self.labelDomain.text = source;
    if ([productGift.status isEqualToString:ProductGiftStatusClaimed]) {
        self.claimStatus.hidden = NO;
        self.buyStatus.hidden = YES;
        [self.btnClaim setImage:[UIImage imageNamed:@"Hearts-26-pink"] forState:UIControlStateNormal];
        if (self.event.isHostEvent && self.productGift.claimerName != nil) {
            self.claimedByLabel.hidden = NO;
            self.claimedByLabel.text = [NSString stringWithFormat:@"Claimed by %@", self.productGift.claimerName];
        }
    }
    if ([productGift.status isEqualToString:ProductGiftBought]) {
        self.claimStatus.hidden = YES;
        self.buyStatus.hidden = NO;
        [self.btnClaim setImage:[UIImage imageNamed:@"Hearts-26-pink"] forState:UIControlStateNormal];
        [self.btnBuy setImage:[UIImage imageNamed:@"Buy-24-pink"] forState:UIControlStateNormal];
        if (self.event.isHostEvent && self.productGift.claimerName != nil) {
            self.claimedByLabel.hidden = NO;
            self.claimedByLabel.text = [NSString stringWithFormat:@"Claimed by %@", self.productGift.claimerName];
        }
    }
}

#pragma mark - actions

- (IBAction)onClaimGift:(id)sender {
    [self.delegate eventProductGiftCell:self didControlClicked:ProductGiftControlTypeClaim];
}

- (IBAction)onUnclaimGift:(id)sender {
    [self.delegate eventProductGiftCell:self didControlClicked:ProductGiftControlTypeUnclaim];
}
- (IBAction)onBuyGift:(id)sender {
    [self.delegate eventProductGiftCell:self didControlClicked:ProductGiftControlTypeBuy];
}

- (IBAction)onDeleteGift:(id)sender {
    [self.delegate eventProductGiftCell:self didControlClicked:ProductGiftControlTypeDelete];
}

@end
