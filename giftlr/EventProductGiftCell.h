//
//  EventProductGiftCell.h
//  giftlr
//
//  Created by Ke Huang on 3/10/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductGift.h"
#import "Event.h"

@class EventProductGiftCell;

@protocol EventProductGiftCellDelegate

-(void)eventProductGiftCell:(EventProductGiftCell *)eventProductGiftCell didDeleteClicked:(BOOL)value;

@end

@interface EventProductGiftCell : UITableViewCell

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) ProductGift *productGift;
@property (assign, nonatomic) BOOL isControlMode;

@property (nonatomic, weak) id<EventProductGiftCellDelegate> delegate;

- (void) showControlView;
- (void) hideControlView;

@end
