//
//  CheckBoxCell.m
//  yelp
//
//  Created by Yingming Chen on 2/12/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "CheckBoxCell.h"

@interface CheckBoxCell ()

- (IBAction)onTouch:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;

@property (nonatomic, assign) BOOL arrowState;

@end

@implementation CheckBoxCell

- (void)awakeFromNib {
    // Initialization code
    self.checked = NO;
    self.lockValue = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onTouch:(id)sender {
    if (!self.lockValue) {
        self.checked = !self.checked;
        // Trigger the event to delegate
        [self.delegate checkBoxCell:self didUpdateValue:self.checked];
    }
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (self.checked) {
        [self.checkImageView setImage:[UIImage imageNamed:@"checked-24"]];
    } else {
        [self.checkImageView setImage:[UIImage imageNamed:@"unchecked-24"]];
    }
}

@end
