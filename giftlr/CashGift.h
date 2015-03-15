//
//  CashGift.h
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Event.h"

extern NSString *const CashGiftStatusUnclaimed;
extern NSString *const CashGiftStatusClaimed;
extern NSString *const CashGiftBought;

@interface CashGift : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDecimalNumber *amount;
@property (strong, nonatomic) NSMutableArray *imageURLs;
@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *hostProfileImageURL;
@property (strong, nonatomic) NSString *claimerFacebookUserID;
@property (nonatomic, strong) NSString *claimerName;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) Event *hostEvent;

-(void)saveToParse;
-(PFObject *)getPFObject;
-(id)initWithPFObject:(PFObject *)pfObject;

@property (strong, nonatomic) PFObject *pfObject;

+(void)loadCashGiftsByEvent:(Event *)event withCallback:(void (^)(NSArray *cashGifts, NSError *error))callback;


@end
