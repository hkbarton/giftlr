//
//  PurchaseViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PurchaseViewController.h"
#import "UIColor+giftlr.h"

@interface PurchaseViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIView *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property (nonatomic, strong) ProductGift *product;

- (IBAction)btnDoneClicked:(id)sender;

@end

@implementation PurchaseViewController

-(id)initWithProduct: (ProductGift *)product {
    if (self = [super init]) {
        self.product = product;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigation bar
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:90.0f/255.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Buy Product";
    // set view style
    self.tabbar.backgroundColor = [UIColor redPinkColor];
    // load web view
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.product.productURL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)btnDoneClicked:(id)sender {
    self.product.status = ProductGiftBought;
    [self.product saveToParse];
    if (self.delegate) {
        [self.delegate purchaseViewController:self didProductGiftBought:self.product];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
