//
//  CashGift.h
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CashGift : NSObject

@property (strong, nonatomic) NSString *cashGiftID;
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *giftDescription;
@property (strong, nonatomic) NSMutableArray *imageURLs;
@property (strong, nonatomic) NSArray *claims;
@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *hostProfileImageURL;

@end
