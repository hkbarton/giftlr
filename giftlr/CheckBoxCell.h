//
//  CheckBoxCell.h
//  yelp
//
//  Created by Yingming Chen on 2/12/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class CheckBoxCell;

@protocol CheckBoxCellDelegate <NSObject>

- (void)checkBoxCell:(CheckBoxCell *)checkBoxCell didUpdateValue:(BOOL)value;

@end

@interface CheckBoxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) BOOL checked;

@property (nonatomic, assign) BOOL lockValue;

@property (nonatomic, strong) User *user;

@property (nonatomic, weak) id<CheckBoxCellDelegate> delegate;

- (void)setChecked:(BOOL)checked;

@end
