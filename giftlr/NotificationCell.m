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
#import "UIImageView+AFNetworking.h"

@interface NotificationCell ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventGiftContainerHeightConstraint;

@end

@implementation NotificationCell

- (void)awakeFromNib {
//    self.contentView.backgroundColor = [UIColor lightGreyBackgroundColor];
//    self.containerView.layer.cornerRadius = 3.0f;
//    self.containerView.clipsToBounds = YES;

    self.userProfileImageView.layer.cornerRadius = 15;
    self.userProfileImageView.clipsToBounds = YES;
    self.eventGiftInfoContainer.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.eventGiftTimeLabel.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.eventGiftNameLabel.backgroundColor = [UIColor lightGreyBackgroundColor];
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
    [User addUserProfileImage:self.userProfileImageView profilePicView:self.activity.fromUserProfilePicView];
    
    if (activity.activityType == ActivityTypeEventInvite) {
        if ([activity.fromUserId isEqualToString:[User currentUser].fbUserId]) {
            self.notificationDetailLabel.text = [NSString stringWithFormat:@"invited %@ to event:", activity.toUserName];
        } else {
            self.notificationDetailLabel.text = @"invited you to event:";
        }
    } else {
        self.notificationDetailLabel.text = activity.detail;
    }
    self.timestampLabel.text = activity.activityDate.timeAgoSinceNow;
    self.userNameLabel.text = activity.fromUserName;
    
    if (activity.event || activity.gift) {
        self.eventGiftInfoContainer.hidden = NO;
        self.eventGiftContainerHeightConstraint.constant = 52;
        if (activity.gift) {
            [self.eventGiftImageView setImageWithURL:[NSURL URLWithString:activity.gift.imageURLs[0]]];
            self.eventGiftNameLabel.text = activity.gift.name;
            NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
            [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
            self.eventGiftTimeLabel.text = [currencyFormat stringFromNumber:activity.gift.price];
        } else {
            self.eventGiftNameLabel.text = activity.event.name;
            self.eventGiftTimeLabel.text = activity.event.startTimeString;
            if (activity.event.profileImage) {
                [self.eventGiftImageView setImage:activity.event.profileImage];
            } else if (activity.event.profileUrl) {
                [self.eventGiftImageView setImageWithURL:[NSURL URLWithString:activity.event.profileUrl] placeholderImage:[UIImage imageNamed:activity.event.defaultEventProfileImage]];
            } else {
                [self.eventGiftImageView setImage:[UIImage imageNamed:activity.event.defaultEventProfileImage]];
            }
        }
    } else {
        self.eventGiftInfoContainer.hidden = YES;
        self.eventGiftContainerHeightConstraint.constant = 0;
    }
}


@end
