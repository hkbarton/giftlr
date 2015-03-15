//
//  SettingMenuTableViewCell.m
//  giftlr
//
//  Created by Ke Huang on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SettingMenuTableViewCell.h"

@interface SettingMenuTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *labelMenu;

@end

@implementation SettingMenuTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setMenuItem:(NSDictionary *)menuItem {
    [self.iconView setImage:[UIImage imageNamed:menuItem[@"icon"]]];
    self.labelMenu.text = menuItem[@"menuDes"];
}

@end
