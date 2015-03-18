//
//  PSCreationTableViewCell.m
//  giftlr
//
//  Created by Ke Huang on 3/18/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PSCreationTableViewCell.h"
#import "PTKView.h"

@interface PSCreationTableViewCell() <PTKViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCreation;

- (IBAction)onBtnCreationClicked:(id)sender;

@property (nonatomic, strong) PTKView *cardInputView;

@end

@implementation PSCreationTableViewCell

NSInteger const CreationType_CreaditCard = 0;
NSInteger const CreationType_Bank = 1;

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (IBAction)onBtnCreationClicked:(id)sender {
    if (self.creationType == CreationType_CreaditCard) {
        if (!self.cardInputView) {
            self.cardInputView = [[PTKView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 20, self.bounds.size.height)];
            // hack here, remove original background
            [self.cardInputView.subviews[0] removeFromSuperview];
            self.cardInputView.delegate = self;
        }
        [self addSubview:self.cardInputView];
        self.cardInputView.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            CGPoint center = self.btnCreation.center;
            center.x += self.frame.size.width/2;
            self.btnCreation.alpha = 0;
            self.btnCreation.center = center;
            self.cardInputView.alpha = 1;
        } completion:nil];
    } else {
        
    }
}

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid {
    if (valid) {
        // TODO
    }
}

@end
