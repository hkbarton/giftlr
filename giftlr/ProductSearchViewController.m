//
//  ProductSearchViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductSearchViewController.h"
#import "ProductGift.h"

@interface ProductSearchViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) UITextField *inputAddress;

@property (nonatomic, strong) NSString *curAddress;
@property (nonatomic, assign) BOOL isWebLoading;

- (IBAction)onAddProductClicked:(id)sender;

@end

NSString *const AddressHome = @"Home";

@implementation ProductSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigation bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:90.0f/255.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // address bar
    self.inputAddress = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 250, 30)];
    UIView *inputAddressPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
    self.inputAddress.leftView = inputAddressPadding;
    self.inputAddress.rightView = inputAddressPadding;
    self.inputAddress.leftViewMode = UITextFieldViewModeAlways;
    self.inputAddress.rightViewMode = UITextFieldViewModeAlways;
    self.inputAddress.layer.cornerRadius = 4.0f;
    self.inputAddress.backgroundColor = [UIColor whiteColor];
    [self.inputAddress setFont:[UIFont systemFontOfSize:14]];
    [self.inputAddress setTextColor:[UIColor darkGrayColor]];
    self.navigationItem.titleView = self.inputAddress;
    // right side button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onHomeClicked)];
    
    // web view
    self.webView.delegate = self;
    [self loadHomeWeb];
    
    // init data
    self.curAddress = AddressHome;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark event handle

- (void)onHomeClicked {
    [self loadHomeWeb];
}

#pragma mark util

- (void)loadHomeWeb{
    NSURL *homeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"prd-search-home" ofType:@"html" inDirectory:@"Html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:homeURL]];
    self.curAddress = AddressHome;
    self.inputAddress.text = self.curAddress;
}

#pragma mark web view

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.isWebLoading = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.isWebLoading = NO;
    self.curAddress = [self.webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    if (self.curAddress == nil || [self.curAddress isEqual:@""] || [self.curAddress rangeOfString:@"http"].location != 0) {
        self.curAddress = AddressHome;
    }
    self.inputAddress.text = self.curAddress;
}

#pragma mark bottom tab bar

- (IBAction)onAddProductClicked:(id)sender {
    if (![self.curAddress isEqual:AddressHome]) {
        NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
        ProductGift *productGift = [ProductGift parseProductFromWeb:[NSURL URLWithString:self.curAddress] withHTML:html];
        NSLog(@"%@", productGift.name);
        NSLog(@"%@", productGift.productURL);
        NSLog(@"%@", [productGift.price stringValue]);
        if (productGift.imageURLs) {
            NSLog(@"%@", productGift.imageURLs[0]);
        }
    }
}

@end
