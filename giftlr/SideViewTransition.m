//
//  SideViewTransition.m
//  giftlr
//
//  Created by Ke Huang on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SideViewTransition.h"

NSString *const LeftSideDirection = @"LeftSideDirection";
NSString *const RightSideDirection = @"RightSideDirection";

CGFloat const AnimationTime = 0.25f;

@interface SideViewTransition()

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, strong) UIView *modalBgView;
@property (nonatomic, weak)UIViewController *targetViewController;
@property (nonatomic, strong) NSString *sideDirection;

@end

@implementation SideViewTransition

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresenting = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return AnimationTime;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.isPresenting) {
        if (!self.modalBgView) {
            self.modalBgView = [[UIView alloc] initWithFrame:fromViewController.view.bounds];
            [self.modalBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onModalBgViewTap)]];
            self.modalBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        }
        [containerView addSubview:self.modalBgView];
        [containerView addSubview:toViewController.view];
        CGRect sideViewFromRect = CGRectMake(0, 0, fromViewController.view.frame.size.width * 0.6, fromViewController.view.frame.size.height);
        CGRect sideViewToRect = CGRectMake(0, 0, fromViewController.view.frame.size.width * 0.6, fromViewController.view.frame.size.height);
        if ([self.sideDirection isEqualToString:LeftSideDirection]) {
            sideViewFromRect.origin.x = -sideViewFromRect.size.width;
            sideViewToRect.origin.x = 0;
        } else if ([self.sideDirection isEqualToString:RightSideDirection]) {
            sideViewFromRect.origin.x = fromViewController.view.frame.size.width;
            sideViewToRect.origin.x = fromViewController.view.frame.size.width - sideViewFromRect.size.width;
        }
        toViewController.view.frame = sideViewFromRect;
        self.modalBgView.alpha = 0;
        [UIView animateWithDuration:AnimationTime animations:^{
            self.modalBgView.alpha = 1;
            toViewController.view.frame = sideViewToRect;
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    } else {
        [UIView animateWithDuration:AnimationTime animations:^{
            self.modalBgView.alpha = 0;
            CGRect frame = fromViewController.view.frame;
            if ([self.sideDirection isEqualToString:LeftSideDirection]) {
                frame.origin.x = -frame.size.width;
            } else if ([self.sideDirection isEqualToString:RightSideDirection]) {
                frame.origin.x = toViewController.view.frame.size.width;
            }
            fromViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            [self.modalBgView removeFromSuperview];
            [fromViewController.view removeFromSuperview];
        }];
    }
}

- (void)onModalBgViewTap {
    if (self.targetViewController) {
        [self.targetViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

+(SideViewTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController andSideDirection:(NSString *) sideDirection {
    SideViewTransition *result = [[SideViewTransition alloc] init];
    result.targetViewController = targetViewController;
    targetViewController.modalPresentationStyle = UIModalPresentationCustom;
    result.sideDirection = sideDirection;
    return result;
}

@end
