//
//  PSCreationTableViewCell.m
//  giftlr
//
//  Created by Ke Huang on 3/18/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PSCreationTableViewCell.h"
#import "PTKView.h"
#import "PTKTextField.h"

@interface PSCreationTableViewCell() <PTKViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCreation;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

- (IBAction)onBtnCreationClicked:(id)sender;
- (IBAction)btnOKClicked:(id)sender;
- (IBAction)btnCancelClicked:(id)sender;

@property (nonatomic, strong) PTKView *cardInputView;

@property (nonatomic, assign) CGPoint oriCenterOfCreationButton;

@end

@implementation PSCreationTableViewCell

NSInteger const CreationType_CreaditCard = 0;
NSInteger const CreationType_Bank = 1;

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.btnOK setImage:[UIImage imageNamed:@"ps-ok"] forState:UIControlStateNormal];
    [self.btnOK setImage:[UIImage imageNamed:@"ps-ok-disable"] forState:UIControlStateDisabled];
    [self.btnCancel setImage:[UIImage imageNamed:@"ps-cancel"] forState:UIControlStateNormal];
    self.btnOK.enabled = NO;
    self.btnOK.hidden = YES;
    self.btnCancel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCreationType:(NSInteger)creationType {
    _creationType = creationType;
    if (self.creationType == CreationType_CreaditCard) {
        [self.btnCreation setImage:[UIImage imageNamed:@"add-card"] forState:UIControlStateNormal];
    } else {
        [self.btnCreation setImage:[UIImage imageNamed:@"add-bank"] forState:UIControlStateNormal];
    }
}

- (void)hideInputView {
    if (self.creationType == CreationType_CreaditCard) {
        [UIView animateWithDuration:0.2 animations:^{
            self.cardInputView.alpha = 0;
            self.btnOK.alpha = 0;
            self.btnCancel.alpha = 0;
        } completion:^(BOOL finished) {
            [self.cardInputView removeFromSuperview];
            self.btnOK.hidden = YES;
            self.btnCancel.hidden = YES;
            [UIView animateWithDuration:0.2 animations:^{
                self.btnCreation.center = self.oriCenterOfCreationButton;
                self.btnCreation.alpha = 1;
            }];
        }];
    } else {
        
    }
}

- (IBAction)onBtnCreationClicked:(id)sender {
    if (self.creationType == CreationType_CreaditCard) {
        if (!self.cardInputView) {
            self.cardInputView = [[PTKView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 20, self.bounds.size.height)];
            // hack here, remove original background
            [self.cardInputView.subviews[0] removeFromSuperview];
            self.cardInputView.delegate = self;
        }
        [self addSubview:self.cardInputView];
        [self sendSubviewToBack:self.cardInputView];
        self.cardInputView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            self.oriCenterOfCreationButton = self.btnCreation.center;
            CGPoint center = self.btnCreation.center;
            center.x += self.frame.size.width/2;
            self.btnCreation.alpha = 0;
            self.btnCreation.center = center;
            self.cardInputView.alpha = 1;
        } completion:^(BOOL finished) {
            self.btnOK.hidden = NO;
            self.btnCancel.hidden = NO;
            self.btnOK.alpha = 0;
            self.btnCancel.alpha = 0;
            //[self.cardInputView.cardNumberField becomeFirstResponder];
            [UIView animateWithDuration:0.3 animations:^{
                self.btnOK.alpha = 1;
                self.btnCancel.alpha = 1;
            }];
        }];
    } else {
        
    }
}

- (IBAction)btnOKClicked:(id)sender {
    [self hideInputView];
}

- (IBAction)btnCancelClicked:(id)sender {
    [self hideInputView];
    self.cardInputView.cardNumberField.text = @"";
    self.cardInputView.cardExpiryField.text = @"";
    self.cardInputView.cardCVCField.text = @"";
    self.btnOK.enabled = NO;
}

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid {
    self.btnOK.enabled = valid;
}

@end
