//
//  EventCashGiftCell.m
//  giftlr
//
//  Created by Ke Huang on 3/10/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventCashGiftCell.h"
#import "CashGift.h"
#import "UIColor+giftlr.h"

@interface EventCashGiftCell() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fulfilledLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *btnClaim;
@property (weak, nonatomic) IBOutlet UIButton *btnUnclaim;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UILabel *claimByLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTrailingConstraint;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureReconginzer;

@end

@implementation EventCashGiftCell

- (void)awakeFromNib {
    self.controlView.hidden = YES;
    self.tapGestureReconginzer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideControlView)];
    self.tapGestureReconginzer.delegate = self;
    self.isControlMode = NO;
    self.claimByLabel.hidden = YES;
    self.btnClaim.backgroundColor = [UIColor redPinkColor];
    [self hideAllControlButtons];
}

- (void)hideAllControlButtons {
    self.btnClaim.hidden = YES;
    self.btnDelete.hidden = YES;
    self.btnUnclaim.hidden = YES;
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
    self.amountLabel.text = [currencyFormat stringFromNumber:cashGift.amount];
}

- (void)showControlView {
    NSInteger newConstraint;
    [self hideAllControlButtons];
    newConstraint = -80;
    if (self.event.isHostEvent) {
        self.btnDelete.hidden = NO;
    } else {
        if ([self.cashGift.status isEqualToString:CashGiftStatusUnclaimed]){
            self.btnClaim.hidden = NO;
        } else if ([self.cashGift.status isEqualToString:CashGiftStatusClaimed]){
            self.btnUnclaim.hidden = NO;
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

- (IBAction)onClaimGift:(id)sender {
    [self.delegate eventCashGiftCell:self didControlClicked:CashGiftControlTypeClaim];
}

- (IBAction)onUnclaimGift:(id)sender {
    [self.delegate eventCashGiftCell:self didControlClicked:CashGiftControlTypeUnclaim];
}

- (IBAction)onDeleteGift:(id)sender {
    [self.delegate eventCashGiftCell:self didControlClicked:CashGiftControlTypeDelete];
}

@end
