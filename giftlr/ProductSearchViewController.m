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
#import "UIColor+giftlr.h"
#import "ModalViewTransition.h"

@interface ProductSearchViewController () <UIWebViewDelegate, UISearchBarDelegate, ProductDetailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *btnWebBack;
@property (weak, nonatomic) IBOutlet UIButton *btnWebNext;
@property (weak, nonatomic) IBOutlet UIButton *btnAddProduct;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSString *curAddress;
@property (nonatomic, strong) Event *hostEvent;

@property (nonatomic, strong) ModalViewTransition *productDetailViewTransition;

- (IBAction)onAddProductClicked:(id)sender;
- (IBAction)btnWebBackClicked:(id)sender;
- (IBAction)btnWebNextClicked:(id)sender;

@end

NSString *const AddressHome = @"";

@implementation ProductSearchViewController

-(id)initWithHostEvent:(Event *) hostEvent {
    if (self = [super init]) {
        self.hostEvent = hostEvent;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigation bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barTintColor = [UIColor redPinkColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    // address bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.keyboardType = UIKeyboardTypeURL;
    self.searchBar.returnKeyType = UIReturnKeyGo;
    self.searchBar.placeholder = @"Search Google Or Enter Address";
    [self.searchBar setTintColor:[UIColor whiteColor]];
    
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    // right side buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onCloseClicked)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onHomeClicked)];
    // web view
    self.webView.delegate = self;
    [self loadHomeWeb];
    // tab bar
    self.btnAddProduct.enabled = NO;
    // init data
    self.curAddress = AddressHome;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)productDetailViewController:(ProductDetailViewController *)productDetailViewController didProductGiftAdd:(ProductGift *)productGift {
    if (self.delegate) {
        [self.delegate productSearchViewController:self didProductGiftAdd:productGift];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark event handle

- (void)onHomeClicked {
    [self loadHomeWeb];
}

- (void)onCloseClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    productGift.hostEvent = self.hostEvent;
    ProductDetailViewController *pdvc = [[ProductDetailViewController alloc] initWithProduct:productGift andMode:ProductDetailViewModeAdd];
    pdvc.delegate = self;
    pdvc.modalPresentationStyle = UIModalPresentationCustom;
    self.productDetailViewTransition = [ModalViewTransition newTransitionWithTargetViewController:pdvc];
    pdvc.transitioningDelegate = self.productDetailViewTransition;
    [self presentViewController:pdvc animated:YES completion:nil];
}

#pragma mark web view

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self refreshWebToolbarStatus];
    [self.searchBar resignFirstResponder];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.curAddress = [self.webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    if (self.curAddress == nil || [self.curAddress isEqual:@""] || [self.curAddress rangeOfString:@"http"].location != 0) {
        self.curAddress = AddressHome;
    }
    self.searchBar.text = self.curAddress;
    self.btnAddProduct.enabled = [ProductGift isProductParseAbleFromWeb:[NSURL URLWithString:self.curAddress] withHTML:[self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"]];
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
    if (self.btnAddProduct.enabled) {
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
