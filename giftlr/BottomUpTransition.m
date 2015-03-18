//
//  BottomUpTransition.m
//  giftlr
//
//  Created by Ke Huang on 3/17/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "BottomUpTransition.h"

@interface BottomUpTransition()

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, strong) UIView *modalBgView;
@property (nonatomic, weak)UIViewController *targetViewController;

@end

@implementation BottomUpTransition

CGFloat const BottomUpTransition_AnimationTime = 0.25f;

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresenting = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return BottomUpTransition_AnimationTime;
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
        CGRect mainFrame = fromViewController.view.frame;
        CGFloat widthOfTargetView = mainFrame.size.width * 0.9;
        CGFloat heightOfTargetView = mainFrame.size.height * 0.7;
        CGRect targetViewFromRect = CGRectMake(mainFrame.size.width/2 - widthOfTargetView/2, mainFrame.size.height, widthOfTargetView, heightOfTargetView);
        CGRect targetViewToRect = CGRectMake(mainFrame.size.width/2 - widthOfTargetView/2, mainFrame.size.height - heightOfTargetView, widthOfTargetView, heightOfTargetView);
        toViewController.view.frame = targetViewFromRect;
        self.modalBgView.alpha = 0;
        [UIView animateWithDuration:BottomUpTransition_AnimationTime animations:^{
            self.modalBgView.alpha = 1;
            toViewController.view.frame = targetViewToRect;
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    } else {
        [UIView animateWithDuration:BottomUpTransition_AnimationTime animations:^{
            self.modalBgView.alpha = 0;
            CGRect frame = fromViewController.view.frame;
            frame.origin.y = toViewController.view.frame.size.height;
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

+(BottomUpTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController {
    BottomUpTransition *result = [[BottomUpTransition alloc] init];
    result.targetViewController = targetViewController;
    targetViewController.modalPresentationStyle = UIModalPresentationCustom;
    return result;
}

@end
