//
//  EventViewCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"
#import "UIColor+giftlr.h"

@interface EventViewCell ()

@property (weak, nonatomic) IBOutlet UIView *TimeContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;

@end

// hot pink #ff69b4

@implementation EventViewCell

- (void)awakeFromNib {
    // Initialization code
    self.eventHostImageView.layer.cornerRadius = 23;
    self.eventHostImageView.clipsToBounds = YES;
    self.eventHostImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.eventHostImageView.layer.borderWidth = 1;
    
    self.TimeContainerView.layer.cornerRadius = 3;
    self.TimeContainerView.clipsToBounds = YES;
    self.TimeContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.TimeContainerView.layer.borderWidth = 2.5;
    
    self.eventProfilePicView.layer.cornerRadius = 3;
    self.eventProfilePicView.clipsToBounds = YES;

    self.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)toggleOverlay:(BOOL)showing {
    self.eventHostImageView.hidden = !showing;
    self.TimeContainerView.hidden = !showing;
    self.eventNameLabel.hidden = !showing;
}

- (void)setEvent:(Event *)event {
    _event = event;
    self.eventNameLabel.text = event.name;
    self.eventTimeLabel.text = event.startTimeString;
    self.eventLocationLabel.text = event.location;
    self.eventMonthLabel.text = event.startTimeMonth;
    self.eventDayLabel.text = event.startTimeDay;

    [self.eventProfilePicView setImage:nil];
    
    if (event.eventHostId == nil) {
        [event fetchEventDetailWithCompletion:^(NSError *error) {
            [self updateEventDetailView];
        }];
    } else {
        [self updateEventDetailView];
    }
}

- (void) updateEventDetailView {
    if (self.event.profileImage) {
        [self.eventProfilePicView setImage:self.event.profileImage];
    } else if (self.event.profileUrl) {
        [self.eventProfilePicView setImageWithURL:[NSURL URLWithString:self.event.profileUrl] placeholderImage:nil];//[UIImage imageNamed:self.event.defaultEventProfileImage]];
    }else {
        [self.eventProfilePicView setImage:[UIImage imageNamed:self.event.defaultEventProfileImage]];
    }
    
    for (UIView *view in self.eventHostImageView.subviews) {
        [view removeFromSuperview];
    }
    if (!self.event.eventHostProfilePicView) {
        self.event.eventHostProfilePicView = [User createUserProfileImage:self.event.eventHostId];
    }
    [User addUserProfileImage:self.eventHostImageView profilePicView:self.event.eventHostProfilePicView];
}

- (void) zoomEventProfilePic:(BOOL)isZoomOut {
    if (isZoomOut) {
        self.leadingConstraint.constant = 16;
        self.trailingConstraint.constant = 16;
    } else {
        self.leadingConstraint.constant = 32;
        self.trailingConstraint.constant = 32;
    }
    [self.contentView setNeedsLayout];
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
}

@end
