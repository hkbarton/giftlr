//
//  ModalViewTransition.m
//  giftlr
//
//  Created by Ke Huang on 3/14/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ModalViewTransition.h"

@interface ModalViewTransition()

@property (nonatomic, assign) BOOL isPresenting;
@property (nonatomic, strong) UIView *modalBgView;

@property (nonatomic, weak)UIViewController *targetViewController;

@end

@implementation ModalViewTransition

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.isPresenting = YES;
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    self.isPresenting = NO;
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresenting) {
        return 0.7;
    }
    return 0.3;
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
        toViewController.view.center = containerView.center;
        toViewController.view.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        self.modalBgView.alpha = 0;
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
            self.modalBgView.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
            if (self.xScale != 1 || self.yScale != 1) {
                CGSize oldSize = toViewController.view.frame.size;
                CGSize newSize = CGSizeMake(oldSize.width * self.xScale, oldSize.height * self.yScale);
                toViewController.view.frame = CGRectMake(toViewController.view.frame.origin.x + (oldSize.width - newSize.width) / 2, toViewController.view.frame.origin.y + (oldSize.height - newSize.height) / 2, newSize.width, newSize.height);
            }
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.modalBgView.alpha = 0;
            fromViewController.view.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
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

+(ModalViewTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController {
    return [ModalViewTransition newTransitionWithTargetViewController:targetViewController andXScale:1 andYScale:1];
}

+(ModalViewTransition *)newTransitionWithTargetViewController:(UIViewController *)targetViewController andXScale:(CGFloat)xScale andYScale:(CGFloat)yScale {
    ModalViewTransition *result = [[ModalViewTransition alloc] init];
    result.targetViewController = targetViewController;
    result.xScale = xScale;
    result.yScale = yScale;
    return result;
}

@end
