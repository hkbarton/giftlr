//
//  ProductGift.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductGift.h"

NSString *const ProductGiftStatusUnclaimed = @"ProductGiftStatusUnclaimed";
NSString *const ProductGiftStatusClaimed = @"ProductGiftStatusClaimed";
NSString *const ProductGiftBought = @"ProductGiftBought";

@implementation ProductGift

+(ProductGift*)parseProductFromHTML:(NSString *)html {
    ProductGift *result = [[ProductGift alloc] init];
    return result;
}

@end
