//
//  EventCashGiftCell.h
//  giftlr
//
//  Created by Ke Huang on 3/10/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "CashGift.h"

typedef NS_ENUM(NSInteger, CashGiftControlType) {
    CashGiftControlTypeClaim = 0,
    CashGiftControlTypeUnclaim = 1,
    CashGiftControlTypeDelete = 2
};

@class EventCashGiftCell;

@protocol EventCashGiftCellDelegate

-(void)eventCashGiftCell:(EventCashGiftCell *)eventCashGiftCell didControlClicked:(CashGiftControlType)value;

@end

@interface EventCashGiftCell : UITableViewCell

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) CashGift *cashGift;

@property (assign, nonatomic) BOOL isControlMode;

@property (nonatomic, weak) id<EventCashGiftCellDelegate> delegate;

- (void) showControlView;
- (void) hideControlView;

@end
