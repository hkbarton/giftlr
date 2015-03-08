//
//  ParsePattern.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ParsePattern.h"

@implementation ParsePattern

+(ParsePattern *)defaultParsePattern {
    ParsePattern *result = [[ParsePattern alloc] init];
    result.extractGroupIndex = 1;
    return  result;
}

@end
