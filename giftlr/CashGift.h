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

@interface CashGift : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDecimalNumber *amount;
@property (strong, nonatomic) NSMutableArray *imageURLs;
@property (strong, nonatomic) NSArray *claims;
@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *hostProfileImageURL;
@property (strong, nonatomic) NSString *facebookEventID;
@property (strong, nonatomic) NSString *claimerFacebookUserID;

-(void)saveToParse;
-(PFObject *)getPFObject;
-(id)initWithPFObject:(PFObject *)pfObject;

@property (strong, nonatomic) PFObject *pfObject;

@end
