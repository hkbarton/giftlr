//
//  ProductGiftCell.h
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductGift.h"
#import "CashGift.h"

@interface ProductGiftCell : UITableViewCell

-(void)initWithProductGift:(ProductGift *)productGift;
-(void)initWithCashGift:(CashGift *)cashGift;

@end
