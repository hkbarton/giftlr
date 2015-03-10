//
//  EventViewCell.h
//  giftlr
//
//  Created by Yingming Chen on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventProfilePicView;
@property (weak, nonatomic) IBOutlet UIImageView *eventHostImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDayLabel;

@property (strong, nonatomic) Event *event;

@end
