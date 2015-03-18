//
//  PSCreationTableViewCell.h
//  giftlr
//
//  Created by Ke Huang on 3/18/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentInfo.h"

@class PSCreationTableViewCell;

@protocol PSCreationTableViewCellDelegate

@optional
-(void)psCreationTableViewCell:(PSCreationTableViewCell *)psCreationTableViewCell didPaymentInfoCreate:(PaymentInfo *)payementInfo;

@end

@interface PSCreationTableViewCell : UITableViewCell

@property (nonatomic, assign)NSInteger creationType;
@property (nonatomic, weak)id<PSCreationTableViewCellDelegate> delegate;

@end
