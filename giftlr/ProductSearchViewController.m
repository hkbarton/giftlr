//
//  ProductSearchViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductSearchViewController.h"

@interface ProductSearchViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)onAddProductClicked:(id)sender;

@end

@implementation ProductSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigation bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:90.0f/255.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // load home page
    NSURL *homeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"prd-search-home" ofType:@"html" inDirectory:@"Html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:homeURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark bottom tab bar

- (IBAction)onAddProductClicked:(id)sender {
}

@end
