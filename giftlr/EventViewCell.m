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

@interface EventViewCell ()

@property (weak, nonatomic) IBOutlet UIView *TimeContainerView;

@property (weak, nonatomic) IBOutlet UIImageView *attendingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;

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
    
    self.giftImageView.hidden = YES;
    self.attendingImageView.hidden = YES;
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

    [self.eventProfilePicView setImage:nil];
    
    [event fetchEventDetailWithCompletion:^(NSError *error) {
        [self.eventProfilePicView setImageWithURL:[NSURL URLWithString:event.profileUrl] placeholderImage:[UIImage imageNamed:@"default-event-profile-image"]];
        [User setUserProfileImage:self.eventHostImageView fbUserId:event.eventHostId];

        if ([self.event.eventHostId isEqualToString:[User currentUser].fbUserId]) {
            self.giftImageView.hidden = YES;
            self.attendingImageView.hidden = YES;
        } else {
            self.giftImageView.hidden = NO;
            self.attendingImageView.hidden = NO;
        }
    }];
}

@end
