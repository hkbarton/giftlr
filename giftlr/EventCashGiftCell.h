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

@interface EventCashGiftCell : UITableViewCell

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) CashGift *cashGift;

@end
