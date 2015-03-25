//
//  NotificationCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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
    self.userProfileImageView.layer.cornerRadius = 15;
    self.userProfileImageView.clipsToBounds = YES;
    UIColor *bgColor = [UIColor lightGreyBackgroundColor];
    self.eventGiftInfoContainer.backgroundColor = bgColor;
    self.eventGiftTimeLabel.backgroundColor = bgColor;
    self.eventGiftNameLabel.backgroundColor = bgColor;
    
    self.contentView.backgroundColor = [UIColor lightGreyBackgroundColor];
    
    self.containerView.layer.cornerRadius = 3.0f;
    self.containerView.clipsToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addShadowToContainerView {
    //Adds a shadow to container
    CALayer *layer = self.eventGiftInfoContainer.layer;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 1.5f;
    layer.shadowOpacity = 0.50f;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
}

- (void)layoutSubviews {
    if (self.activity.event || self.activity.gift) {
        [self addShadowToContainerView];
    }
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
        [self addShadowToContainerView];
        
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
