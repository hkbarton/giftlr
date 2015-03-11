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

@interface EventProductGiftCell : UITableViewCell

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) ProductGift *productGift;

@end
