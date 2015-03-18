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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEvent:(Event *)event {
    _event = event;
    self.eventNameLabel.text = event.name;
    self.eventTimeLabel.text = event.startTimeString;
    self.eventLocationLabel.text = event.location;
    self.eventMonthLabel.text = event.startTimeMonth;
    self.eventDayLabel.text = event.startTimeDay;

    [self.eventProfilePicView setImage:[UIImage imageNamed:@"default-event-profile-image"]];
    
    if (event.eventHostId == nil) {
        [event fetchEventDetailWithCompletion:^(NSError *error) {
            [self updateEventDetailView];
        }];
    } else {
        [self updateEventDetailView];
    }
}

- (void) updateEventDetailView {
    if (self.event.profileUrl) {
        [self.eventProfilePicView setImageWithURL:[NSURL URLWithString:self.event.profileUrl] placeholderImage:[UIImage imageNamed:@"default-event-profile-image"]];
    }
    
    for (UIView *view in self.eventHostImageView.subviews) {
        [view removeFromSuperview];
    }
    [User setUserProfileImage:self.eventHostImageView fbUserId:self.event.eventHostId];
}

@end
