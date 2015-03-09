//
//  ProductSearchViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductSearchViewController.h"
#import "ProductGift.h"
#import "ProductDetailViewController.h"
#import "SVProgressHUD.h"

@interface ProductSearchViewController () <UIWebViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *btnWebBack;
@property (weak, nonatomic) IBOutlet UIButton *btnWebNext;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSString *curAddress;
@property (nonatomic, assign) BOOL isWebLoading;
@property (nonatomic, assign) BOOL shouldAddProductAfterLoading;

- (IBAction)onAddProductClicked:(id)sender;
- (IBAction)btnWebBackClicked:(id)sender;
- (IBAction)btnWebNextClicked:(id)sender;

@end

NSString *const AddressHome = @"";

@implementation ProductSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigation bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:90.0f/255.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // address bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.keyboardType = UIKeyboardTypeURL;
    self.searchBar.returnKeyType = UIReturnKeyGo;
    self.searchBar.placeholder = @"Search Google Or Enter Address";
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor whiteColor]];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    // right side buttons
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

- (void)refreshWebToolbarStatus {
    self.btnWebBack.enabled = self.webView.canGoBack;
    self.btnWebNext.enabled = self.webView.canGoForward;
}

- (void)loadHomeWeb{
    NSURL *homeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"prd-search-home" ofType:@"html" inDirectory:@"Html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:homeURL]];
    self.curAddress = AddressHome;
    self.searchBar.text = self.curAddress;
}

- (void)addProduct {
    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    ProductGift *productGift = [ProductGift parseProductFromWeb:[NSURL URLWithString:self.curAddress] withHTML:html];
    ProductDetailViewController *pdvc = [[ProductDetailViewController alloc] initWithProduct:productGift];
    [self.navigationController pushViewController:pdvc animated:YES];
}

#pragma mark web view

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.isWebLoading = YES;
    self.shouldAddProductAfterLoading = NO;
    [self refreshWebToolbarStatus];
    [self.searchBar resignFirstResponder];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.isWebLoading = NO;
    [SVProgressHUD dismiss];
    self.curAddress = [self.webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    if (self.curAddress == nil || [self.curAddress isEqual:@""] || [self.curAddress rangeOfString:@"http"].location != 0) {
        self.curAddress = AddressHome;
    }
    self.searchBar.text = self.curAddress;
    if (self.shouldAddProductAfterLoading) {
        self.shouldAddProductAfterLoading = NO;
        [self addProduct];
    }
}

#pragma mark - Search Bar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = self.curAddress;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchBarText = searchBar.text;
    NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:@"^(http|https)\\:\\/\\/.+$" options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *urlMatch = [urlRegex firstMatchInString:searchBarText options:0 range:NSMakeRange(0, [searchBarText length])];
    if (urlMatch.range.location != NSNotFound && urlMatch.range.length > 0) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:searchBarText]]];
    } else {
        NSString *urlEncodeSearchText =[searchBarText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSMutableString *searchURL = [NSMutableString stringWithString:@"https://www.google.com/webhp?hl=en#safe=off&hl=en&q="];
        [searchURL appendString:urlEncodeSearchText];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:searchURL]]];
    }
}

#pragma mark bottom tab bar

- (IBAction)onAddProductClicked:(id)sender {
    if (![self.curAddress isEqual:AddressHome]) {
        if (self.isWebLoading) {
            [SVProgressHUD show];
            self.shouldAddProductAfterLoading = YES;
            return;
        }
        [self addProduct];
    }
}

- (IBAction)btnWebBackClicked:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (IBAction)btnWebNextClicked:(id)sender {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

@end
