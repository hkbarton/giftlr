//
//  PSTableViewCell.h
//  giftlr
//
//  Created by Ke Huang on 3/18/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentInfo.h"

@interface PSTableViewCell : UITableViewCell

@property (nonatomic, strong) PaymentInfo *paymentInfo;

@end
