//
//  NotificationCell.h
//  giftlr
//
//  Created by Yingming Chen on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"

@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *notificationDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *eventGiftInfoContainer;
@property (weak, nonatomic) IBOutlet UIImageView *eventGiftImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventGiftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventGiftTimeLabel;

@property (strong, nonatomic) Activity *activity;

- (void)addShadowToContainerView;

@end
