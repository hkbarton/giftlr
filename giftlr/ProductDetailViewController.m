//
//  ProductDetailViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductDetailTextView.h"
#import "PurchaseViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"

NSString *const ProductDetailViewModeAdd = @"ProductDetailViewModeAdd";
NSString *const ProductDetailViewModeView = @"ProductDetailViewModeView";

@interface ProductDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *btnAddGift;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;
@property (weak, nonatomic) IBOutlet UIButton *btnClaim;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageProduct;
@property (strong, nonatomic) ProductDetailTextView *productDetailTextView;

@property (nonatomic, strong) ProductGift *product;
@property (nonatomic, strong) NSString *mode;

- (IBAction)onBtnAddGiftClicked:(id)sender;
- (IBAction)onBtnBuyClicked:(id)sender;
- (IBAction)onBtnClaimClicked:(id)sender;

@end

@implementation ProductDetailViewController

-(id)initWithProduct: (ProductGift *)product andMode:(NSString *)mode{
    if (self = [super init]) {
        self.product = product;
        self.mode = mode;
    }
    return self;
}

- (void) updateActionButtonStatus {
    if ([self.mode isEqualToString:ProductDetailViewModeAdd]) {
        self.btnAddGift.hidden = NO;
        self.btnClaim.hidden = YES;
        self.btnBuy.hidden = YES;
    } else if ([self.mode isEqualToString:ProductDetailViewModeView]) {
        self.btnAddGift.hidden = YES;
        self.btnClaim.hidden = NO;
        self.btnBuy.hidden = NO;
        if ([[User currentUser].fbUserId isEqualToString: self.product.hostEvent.eventHostId]) {
            self.btnClaim.hidden = YES;
            self.btnBuy.hidden = YES;
        } else {
            if ([self.product.status isEqualToString: ProductGiftStatusClaimed] || [self.product.status isEqualToString:ProductGiftBought]) {
                self.btnClaim.hidden = YES;
            }
            if ([self.product.status isEqualToString: ProductGiftBought] || [self.product.status isEqualToString:ProductGiftStatusUnclaimed]) {
                self.btnBuy.hidden = YES;
            }
        }
    }
}

- (void)initSubView {
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, navigationBarHeight + statusBarHeight, appFrame.size.width, appFrame.size.height - self.tabbar.frame.size.height - navigationBarHeight)];
    self.imageProduct = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, appFrame.size.width, 300)];
    self.imageProduct.contentMode = UIViewContentModeScaleAspectFit;
    self.imageProduct.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageProduct];
    self.productDetailTextView = [[ProductDetailTextView alloc] initWithFrame:CGRectMake(0, 300, appFrame.size.width, 300)];
    [self.scrollView addSubview:self.productDetailTextView];
    self.scrollView.contentSize = CGSizeMake(appFrame.size.width, 600);
    [self.view addSubview:self.scrollView];
    // setup different button by different mode
    [self updateActionButtonStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // navigation bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:90.0f/255.0f green:90.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Product Gift";
    // init view
    [self initSubView];
    // set data
    if (self.product.imageURLs!=nil && [self.product.imageURLs count] > 0) {
        [self loadImage:self.imageProduct withURL:self.product.imageURLs[0]];
    } else {
        // TODO set default image
    }
    self.productDetailTextView.product = self.product;
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateActionButtonStatus];
}

- (void)loadImage:(__weak UIImageView *)imageView withURL:(NSString *)url {
    NSURL *imageURL = [NSURL URLWithString:url];
    NSURLRequest *posterRequest = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:3.0f];
    [imageView setImageWithURLRequest:posterRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        imageView.image = image;
        // Only animate image fade in when result come from network
        if (response != nil) {
            imageView.alpha = 0;
            [UIView animateWithDuration:0.5f animations:^{
                imageView.alpha = 1.0f;
            }];
        }
    } failure:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onBtnAddGiftClicked:(id)sender {
    self.product = [self.productDetailTextView getUpdatedProductGift];
    [self.product saveToParse];
    if (self.delegate) {
        [self.delegate productDetailViewController:self didProductGiftAdd:self.product];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBtnBuyClicked:(id)sender {
    PurchaseViewController *pvc = [[PurchaseViewController alloc] initWithProduct:self.product];
    UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    [self presentViewController:pnvc animated:YES completion:nil];
}

- (IBAction)onBtnClaimClicked:(id)sender {
    self.product.claimerFacebookUserID = [User currentUser].fbUserId;
    self.product.status = ProductGiftStatusClaimed;
    [self.product saveToParse];
    [self updateActionButtonStatus];
}

@end
