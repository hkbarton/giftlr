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

// Specify the width % of the new view against the current view
@property (nonatomic, assign) CGFloat widthPercent;
@property (nonatomic, assign) CGFloat AnimationTime;
// If this is 0, From view will not be slided. If it is 1, it means you want to slide the From view completely
// out of the screen on the same direction as the ToView
@property (nonatomic, assign) CGFloat slideFromViewPercent;
@property (nonatomic, assign) BOOL addModalBgView;

+(SideViewTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController andSideDirection:(NSString *) sideDirection;

@end
