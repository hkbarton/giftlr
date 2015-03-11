//
//  EventDetailViewCell.m
//  giftlr
//
//  Created by Yingming Chen on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventDetailViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"

@interface EventDetailViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *eventProfilePicView;
@property (weak, nonatomic) IBOutlet UIImageView *eventHostImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventHostedByLabel;

@end

@implementation EventDetailViewCell

- (void)awakeFromNib {
    // grey 130/136/138
    self.eventHostImageView.layer.cornerRadius = 23;
    self.eventHostImageView.clipsToBounds = YES;
    self.eventHostImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.eventHostImageView.layer.borderWidth = 1;

    UIColor *textGreyColor = [UIColor  colorWithRed:130.0f/255.0f green:136.0f/255.0f blue:138.0f/255.0f alpha:1.0f];
    self.eventHostedByLabel.textColor = textGreyColor;
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
    self.eventHostedByLabel.text = [NSString stringWithFormat:@"Hosted by %@", event.eventHostName];
    
    [self.eventProfilePicView setImage:nil];
    
    [self.eventProfilePicView setImageWithURL:[NSURL URLWithString:event.profileUrl] placeholderImage:[UIImage imageNamed:@"default-event-profile-image"]];
    [User setUserProfileImage:self.eventHostImageView fbUserId:event.eventHostId];
}

@end
