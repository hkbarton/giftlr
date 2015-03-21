//
//  NotificationCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "NotificationCell.h"
#import "NSDate+DateTools.h"

@implementation NotificationCell

- (void)awakeFromNib {
    // Initialization code
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
