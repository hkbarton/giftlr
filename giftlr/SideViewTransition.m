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

@interface SideViewTransition()

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, strong) UIView *modalBgView;
@property (nonatomic, weak)UIViewController *targetViewController;
@property (nonatomic, strong) NSString *sideDirection;

@end

@implementation SideViewTransition

- (id)init {
    self = [super init];
    if (self) {
        self.widthPercent = 0.6;
        self.AnimationTime = 0.25f;
        self.addModalBgView = YES;
        self.slideFromViewPercent = 0;
    }
    
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresenting = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.AnimationTime;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.isPresenting) {
        if (!self.modalBgView && self.addModalBgView) {
            self.modalBgView = [[UIView alloc] initWithFrame:fromViewController.view.bounds];
            [self.modalBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onModalBgViewTap)]];
            self.modalBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        }
        if (self.addModalBgView) {
            [containerView addSubview:self.modalBgView];
        }
        
        [containerView addSubview:toViewController.view];
        CGRect sideViewFromRect = CGRectMake(0, 0, fromViewController.view.frame.size.width * self.widthPercent, fromViewController.view.frame.size.height);
        CGRect sideViewToRect = CGRectMake(0, 0, fromViewController.view.frame.size.width * self.widthPercent, fromViewController.view.frame.size.height);
        CGRect fromViewToRect = CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
        if ([self.sideDirection isEqualToString:LeftSideDirection]) {
            sideViewFromRect.origin.x = -sideViewFromRect.size.width;
            sideViewToRect.origin.x = 0;
            fromViewToRect.origin.x = fromViewToRect.size.width*self.slideFromViewPercent;
        } else if ([self.sideDirection isEqualToString:RightSideDirection]) {
            sideViewFromRect.origin.x = fromViewController.view.frame.size.width;
            sideViewToRect.origin.x = fromViewController.view.frame.size.width - sideViewFromRect.size.width;
            fromViewToRect.origin.x = -fromViewToRect.size.width*self.slideFromViewPercent;
        }
        toViewController.view.frame = sideViewFromRect;
        if (self.addModalBgView) {
            self.modalBgView.alpha = 0;
        }
        [UIView animateWithDuration:self.AnimationTime animations:^{
            if (self.addModalBgView) {
                self.modalBgView.alpha = 1;
            }
            toViewController.view.frame = sideViewToRect;
            fromViewController.view.frame = fromViewToRect;
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    } else {
        [UIView animateWithDuration:self.AnimationTime animations:^{
            if (self.addModalBgView) {
                self.modalBgView.alpha = 0;
            }
            CGRect frame = fromViewController.view.frame;
            CGRect toViewToRect = CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height);
            toViewController.view.frame = toViewToRect;
            
            if ([self.sideDirection isEqualToString:LeftSideDirection]) {
                frame.origin.x = -frame.size.width;
            } else if ([self.sideDirection isEqualToString:RightSideDirection]) {
                frame.origin.x = toViewController.view.frame.size.width;
            }
            fromViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
            if (self.addModalBgView) {
                [self.modalBgView removeFromSuperview];
            }
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
