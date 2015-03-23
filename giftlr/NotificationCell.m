//
//  NotificationCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "NotificationCell.h"
#import "NSDate+DateTools.h"
#import "UIColor+giftlr.h"

@interface NotificationCell ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation NotificationCell

- (void)awakeFromNib {
    // Initialization code
    self.notificationDetailLabel.textColor = [UIColor darkGrayColor];
    self.contentView.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.containerView.layer.cornerRadius = 3.0f;
    self.containerView.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActivity:(Activity *)activity{
    _activity = activity;
    for (UIView *view in self.userProfileImageView.subviews) {
        [view removeFromSuperview];
    }
    [User setUserProfileImage:self.userProfileImageView fbUserId:activity.fromUserId];
    self.notificationDetailLabel.text = activity.detail;
    self.timestampLabel.text = activity.activityDate.timeAgoSinceNow;
}


@end
