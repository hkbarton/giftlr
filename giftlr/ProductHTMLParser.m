//
//  ProductHTMLParser.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductHTMLParser.h"

NSString *const CommonParserKey = @"COMMON";
NSString *const NamePatternKey = @"name";
NSString *const ImageURLPatternKey = @"img";
NSString *const PricePatternKey = @"price";
NSString *const URLPatternKey = @"url";

@implementation ProductHTMLParser

static NSDictionary *_ParserData;

+(NSDictionary *)ParserData {
    if (_ParserData==nil) {
        _ParserData = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSArray arrayWithObjects:
                         @"property=\"og\\:title\"[^<>]+content=\"([^<>\"]*)\"",
                         @"content=\"([^<>\"]*)\"[^<>]+property=\"og\\:title\"",
                         @"content=\'([^<>\']*)\'[^<>]+property=\"og\\:title\"",
                         @"<[^<>]+title[^<>]*>([^<>]*)</\\w+\\d*>", nil],NamePatternKey,
                        [NSArray arrayWithObjects:
                         @"property=\"og\\:image\"[^<>]+content=\"([^<>\"]*)\"",
                         @"content=\"([^<>\"]*)\"[^<>]+property=\"og\\:image\"",
                         @"<img[^<>]+src=\"([^<>]+\\.jpg)\"[^<>]*>", nil], ImageURLPatternKey,
                        [NSArray arrayWithObjects:
                         @"2`property=\"og\\:price(\\:amount)?\"[^<>]+content=\"([^<>\"]*)\"",
                         @"content=\"([^<>\"]*)\"[^<>]+property=\"og\\:price(\\:amount)?\"",
                         @"\\$([\\d\\,]+\\.\\d{1,2})", nil], PricePatternKey, nil], CommonParserKey,
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSArray arrayWithObjects:
                         @"<title>([^<>]+)</title>",
                         nil],NamePatternKey,
                        [NSArray arrayWithObjects:
                         @"<img[^<>]*src=\"([^<>\"]+)\"[^<>]+id=\"main-image\"[^<>]*>",
                         nil], ImageURLPatternKey,
                        [NSArray arrayWithObjects:
                         @"2`(priceLarge|current-price|priceblock_ourprice)[^<]+\\$([\\d\\,]+\\.\\d{1,2})",
                         nil], PricePatternKey, nil], @"amazon.com",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSArray arrayWithObjects:
                         @"<[^<>]+class=\"PdpImageIMG\"[^<>]*>[^<>]*<a[^<>]+>[^<>]*<img[^<>]+src=\"([^<>\"]+\\.jpg)[^<>]*\"[^<>]*>",
                         nil], ImageURLPatternKey,
                        [NSArray arrayWithObjects:
                         @"<[^<>]+class=\"basePrice\"[^<>]*>\\$([\\d\\.]+)<[^<>]+>",
                         nil], PricePatternKey, nil], @"bestbuy.com",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSArray arrayWithObjects:
                         @"<[^<>]+class=\"m-product-price-amt\"[^<>]*>\\$([\\d\\.]+)<[^<>]+>",
                         nil], PricePatternKey, nil], @"macys.com",
                       
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSArray arrayWithObjects:
                         @"<[^<>]+rel=\"canonical\"[^<>]*href=\"([^<>\"]+)\">",
                         nil],URLPatternKey,
                        [NSArray arrayWithObjects:
                         @"<[^<>]+class=\"b-name\"[^<>]*>([^<>]+)<[^<>]+>",
                         nil],NamePatternKey,
                        [NSArray arrayWithObjects:
                         @"<img[^<>]*src=\"([^<>\"]+)\"[^<>]*class=\"b-pdp-image\"[^<>]+>",
                         nil], ImageURLPatternKey,
                        [NSArray arrayWithObjects:
                         @"itemprop=[\'\"]price[\'\"][^\\n]*\\$([\\d\\,]+\\.\\d+)",
                         nil], PricePatternKey, nil], @"bloomingdales.com",
                       
                       /* Template
                       [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSArray arrayWithObjects:
                        @""
                        @"", nil],NamePatternKey,
                        [NSArray arrayWithObjects:
                        @""
                        @"", nil], ImageURLPatternKey,
                        [NSArray arrayWithObjects:
                        @""
                        @"", nil], PricePatternKey, nil], @"",
                        */
                       
                       nil];
    }
    return _ParserData;
}

+(NSString *)getDomainFromURL:(NSURL *) url {
    NSString *host = url.host;
    NSRegularExpression *domainRegex = [NSRegularExpression regularExpressionWithPattern:@"([\\w\\d]+\\.)?([\\w\\d]+\\.\\w+)" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *domainMatch = [domainRegex firstMatchInString:host options:0 range:NSMakeRange(0, [host length])];
    NSRange domainRange = [domainMatch rangeAtIndex:2];
    if (domainRange.location != NSNotFound && domainRange.length > 0) {
        return [host substringWithRange:domainRange];
    }
    return nil;
}

+(NSArray *)getPatternsFromPatternData:(NSArray *)patternData {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < [patternData count]; i++) {
        NSString *patternStr = [patternData objectAtIndex:i];
        NSArray *patternStrParts = [patternStr componentsSeparatedByString:@"`"];
        ParsePattern *parsePattern = [ParsePattern defaultParsePattern];
        if ([patternStrParts count] > 1) {
            parsePattern.extractGroupIndex = [patternStrParts[0] integerValue];
            parsePattern.pattern = patternStrParts[1];
        } else {
            parsePattern.pattern = patternStrParts[0];
        }
        [result addObject:parsePattern];
    }
    return result;
}

+(NSMutableArray *)getPatterns:(NSArray *)domainPatterns withCommonPatterns:(NSArray *)commonPatterns {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (domainPatterns!=nil && [domainPatterns count] > 0) {
        [result addObjectsFromArray:[ProductHTMLParser getPatternsFromPatternData:domainPatterns]];
    } else if (commonPatterns!=nil && [commonPatterns count] > 0) {
        [result addObjectsFromArray:[ProductHTMLParser getPatternsFromPatternData:commonPatterns]];
    }
    return result;
}

+(ProductHTMLParser *)getParserByURL:(NSURL *)url {
    NSString *domain = [ProductHTMLParser getDomainFromURL:url];
    if (domain != nil) {
        NSDictionary *parserData = [[ProductHTMLParser ParserData] objectForKey:domain];
        NSDictionary *commonParserData = [[ProductHTMLParser ParserData] objectForKey:CommonParserKey];
        if (parserData != nil) {
            ProductHTMLParser *result = [[ProductHTMLParser alloc] init];
            result.nameParsePatterns = [ProductHTMLParser getPatterns:[parserData objectForKey:NamePatternKey] withCommonPatterns:[commonParserData objectForKey:NamePatternKey]];
            result.imageURLParsePatterns = [ProductHTMLParser getPatterns:[parserData objectForKey:ImageURLPatternKey] withCommonPatterns:[commonParserData objectForKey:ImageURLPatternKey]];
            result.priceParsePatterns = [ProductHTMLParser getPatterns:[parserData objectForKey:PricePatternKey] withCommonPatterns:[commonParserData objectForKey:PricePatternKey]];
            result.urlParsePatterns = [ProductHTMLParser getPatterns:[parserData objectForKey:URLPatternKey] withCommonPatterns:[commonParserData objectForKey:URLPatternKey]];
            return result;
        }
    }
    return nil;
}

+(NSString *)parseData:(NSString *) data withParsePatterns:(NSArray *)patterns {
    NSString *result = nil;
    for (int i = 0; i < [patterns count]; i++) {
        ParsePattern *parsePattern = (ParsePattern *)patterns[i];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:parsePattern.pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:data options:0 range:NSMakeRange(0, [data length])];
        NSRange matchRange = [match rangeAtIndex:parsePattern.extractGroupIndex];
        if (matchRange.location != NSNotFound && matchRange.length>0) {
            result = [data substringWithRange:matchRange];
            break;
        }
    }
    return result;
}

@end
