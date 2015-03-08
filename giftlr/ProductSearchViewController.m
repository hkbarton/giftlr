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

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.curAddress = webView.request.URL.absoluteString;
    if (self.curAddress == nil || [self.curAddress isEqual:@""] || [self.curAddress rangeOfString:@"http"].location != 0) {
        self.curAddress = AddressHome;
    }
    self.inputAddress.text = self.curAddress;
}

#pragma mark bottom tab bar

- (IBAction)onAddProductClicked:(id)sender {
    if (![self.curAddress isEqual:AddressHome]) {
        NSString *host  = @"fsaf^&(*fdas";
        NSRegularExpression *domainRegex = [NSRegularExpression regularExpressionWithPattern:@"([\\w\\d]+\\.)?([\\w\\d]+\\.\\w+)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *match = [domainRegex firstMatchInString:host options:0 range:NSMakeRange(0, [host length])];
        NSLog(@"%ld", match.range.location);
        NSLog(@"%@", NSStringFromRange([match rangeAtIndex:2]));
    }
}

@end
