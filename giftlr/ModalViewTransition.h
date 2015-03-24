//
//  ModalViewTransition.h
//  giftlr
//
//  Created by Ke Huang on 3/14/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModalViewTransition : NSObject<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

+(ModalViewTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController;

+(ModalViewTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController andXScale:(CGFloat)xScale andYScale:(CGFloat)yScale;

@property (nonatomic, assign) CGFloat xScale;
@property (nonatomic, assign) CGFloat yScale;

@end
