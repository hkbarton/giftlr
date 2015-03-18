//
//  PaymentSettingViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/16/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PaymentSettingViewController.h"

@interface PaymentSettingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onCloseButtonClicked:(id)sender;

@end

@implementation PaymentSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onCloseButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
