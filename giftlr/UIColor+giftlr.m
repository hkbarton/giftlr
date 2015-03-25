//
//  UIColor+giftlr.m
//  giftlr
//
//  Created by Yingming Chen on 3/13/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "UIColor+giftlr.h"

@implementation UIColor (giftlr)

+ (UIColor *) redPinkColor {
    UIColor *redPink = [UIColor  colorWithRed:255.0f/255.0f green:90.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
    return redPink;
}

+ (UIColor *) hotPinkColor {
    UIColor *hotPink = [UIColor  colorWithRed:255.0f/255.0f green:105.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    return hotPink;
}

+ (UIColor *) lightGreyBackgroundColor {
    UIColor *lightGrey = [UIColor  colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    return lightGrey;
}

+ (UIColor *) lightGreyBackgroundColorWithAlpha:(CGFloat)alpha {
    UIColor *lightGrey = [UIColor  colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:alpha];
    return lightGrey;
}

+ (UIColor *) lightGrayBorderColor {
    UIColor *lightGrey = [UIColor  colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f];
    return lightGrey;
}

@end
