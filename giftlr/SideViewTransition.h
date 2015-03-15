//
//  SideViewTransition.h
//  giftlr
//
//  Created by Ke Huang on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const LeftSideDirection;
extern NSString *const RightSideDirection;

@interface SideViewTransition : NSObject<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

+(SideViewTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController andSideDirection:(NSString *) sideDirection;

@end
