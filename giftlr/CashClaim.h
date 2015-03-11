//
//  CashClaim.h
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CashClaim : NSObject

@property (nonatomic, strong) NSString *facebookUserID;
@property (nonatomic, strong) NSDecimalNumber *amount;
@property (nonatomic, strong) NSString *status;

@end
