//
//  ProductGift.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductGift.h"
#import "ProductHTMLParser.h"

NSString *const ProductGiftStatusUnclaimed = @"ProductGiftStatusUnclaimed";
NSString *const ProductGiftStatusClaimed = @"ProductGiftStatusClaimed";
NSString *const ProductGiftBought = @"ProductGiftBought";

@implementation ProductGift

+(ProductGift*)parseProductFromWeb:(NSURL *)url withHTML:(NSString *)html {
    ProductGift *result = [[ProductGift alloc] init];
    ProductHTMLParser *parser = [ProductHTMLParser getParserByURL:url];
    result.name = [ProductHTMLParser parseData:html withParsePatterns:parser.nameParsePatterns];
    if (parser.urlParsePatterns!=nil && [parser.urlParsePatterns count]>0) {
        result.productURL = [ProductHTMLParser parseData:html withParsePatterns:parser.urlParsePatterns];
    } else {
        result.productURL = url.absoluteString;
    }
    NSString *priceStr = [ProductHTMLParser parseData:html withParsePatterns:parser.priceParsePatterns];
    if (priceStr != nil) {
        result.price = [NSDecimalNumber decimalNumberWithString:priceStr];
    } else {
        result.price = [[NSDecimalNumber alloc] initWithFloat:0];
    }
    NSString *imageURL = [ProductHTMLParser parseData:html withParsePatterns:parser.imageURLParsePatterns];
    if (imageURL != nil) {
        result.imageURLs = [NSMutableArray arrayWithObjects:imageURL, nil];
    }
    result.status = ProductGiftStatusUnclaimed;
    return result;
}

@end
