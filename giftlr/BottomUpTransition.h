//
//  BottomUpTransition.h
//  giftlr
//
//  Created by Ke Huang on 3/17/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomUpTransition : NSObject<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

+(BottomUpTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController;

@end
