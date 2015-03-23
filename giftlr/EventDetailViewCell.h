//
//  EventDetailViewCell.h
//  giftlr
//
//  Created by Yingming Chen on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@class EventDetailViewCell;

@protocol EventDetailViewCellDelegate

- (void)eventDetailViewCell:(EventDetailViewCell *)eventDetailViewCell didChangeEventProfileImageTriggered:(BOOL)value;

@end

@interface EventDetailViewCell : UITableViewCell

@property (nonatomic, strong) Event *event;
@property (nonatomic, weak) id<EventDetailViewCellDelegate> delegate;

- (void) setEventProfileImage:(UIImage *)image;
@end
