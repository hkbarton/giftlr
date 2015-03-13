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

@interface ProductSearchViewController () <UIWebViewDelegate, UISearchBarDelegate, ProductDetailViewControllerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *btnWebBack;
@property (weak, nonatomic) IBOutlet UIButton *btnWebNext;
@property (weak, nonatomic) IBOutlet UIButton *btnAddProduct;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *modalBgView;

@property (nonatomic, strong) NSString *curAddress;
@property (nonatomic, strong) Event *hostEvent;

@property (nonatomic, assign) BOOL isPresenting;

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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:255.0f/255.0f green:90.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
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
    pdvc.transitioningDelegate = self;
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

#pragma mark custom transition animation

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
            self.modalBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        }
        [containerView addSubview:self.modalBgView];
        [containerView addSubview:toViewController.view];
        toViewController.view.center = containerView.center;
        toViewController.view.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        self.modalBgView.alpha = 0;
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
            self.modalBgView.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
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


@end
