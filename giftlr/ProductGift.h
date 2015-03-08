//
//  ProductGift.h
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ProductGiftStatusUnclaimed;
extern NSString *const ProductGiftStatusClaimed;
extern NSString *const ProductGiftBought;

@interface ProductGift : NSObject

@property (nonatomic, strong) NSString *giftID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, strong) NSString *productURL;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (nonatomic, strong) NSMutableArray *imageURLs;
@property (nonatomic, strong) NSString *status;

+(ProductGift*)parseProductFromWeb:(NSURL *)url withHTML:(NSString *)html;

@end
