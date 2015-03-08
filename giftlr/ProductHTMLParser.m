//
//  ProductHTMLParser.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductHTMLParser.h"

NSString *const NamePatternKey = @"name";
NSString *const ImageURLPatternKey = @"img";
NSString *const PricePatternKey = @"price";

@implementation ProductHTMLParser

static NSDictionary *_ParserData;

+(NSDictionary *)ParserData {
    if (_ParserData==nil) {
        _ParserData = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"",NamePatternKey,
                        @"", ImageURLPatternKey,
                        @"", PricePatternKey, nil], @"COMMON",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"",NamePatternKey,
                        @"", ImageURLPatternKey,
                        @"", PricePatternKey, nil], @"amazon.com",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"",NamePatternKey,
                        @"", ImageURLPatternKey,
                        @"", PricePatternKey, nil], @"bestbuy.com",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"",NamePatternKey,
                        @"", ImageURLPatternKey,
                        @"", PricePatternKey, nil], @"macys.com",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"",NamePatternKey,
                        @"", ImageURLPatternKey,
                        @"", PricePatternKey, nil], @"bloomingdales.com",
                       
                       /* Template
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        @"",NamePatternKey,
                        @"", ImageURLPatternKey,
                        @"", PricePatternKey, nil], @"",
                        */
                       
                       nil];
    }
    return _ParserData;
}

+(ProductHTMLParser *)getParserByURL:(NSURL *)url {
    ProductHTMLParser *result = [[ProductHTMLParser alloc] init];
    NSString *host = url.host;
    NSRegularExpression *domainRegex = [NSRegularExpression regularExpressionWithPattern:@"([\\w\\d]+\\.)?([\\w\\d]+\\.\\w+)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *domainMatch = [domainRegex firstMatchInString:host options:0 range:NSMakeRange(0, [host length])];
    NSRange domainRange = [domainMatch rangeAtIndex:2];
    if (domainRange.location == NSNotFound || domainRange.length == 0) {
        return nil;
    } else {
        NSString *domain = [host substringWithRange:domainRange];
        //
    }
    return result;
}

@end
