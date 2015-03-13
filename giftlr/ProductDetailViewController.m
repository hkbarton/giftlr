//
//  ProductDetailViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/7/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "PurchaseViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"

NSString *const ProductDetailViewModeAdd = @"ProductDetailViewModeAdd";
NSString *const ProductDetailViewModeView = @"ProductDetailViewModeView";

@interface ProductDetailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtQuantity;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageProduct;
@property (weak, nonatomic) IBOutlet UIView *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *btnAddGift;

@property (nonatomic, strong) ProductGift *product;
@property (nonatomic, strong) NSString *mode;

- (IBAction)onBtnAddGiftClicked:(id)sender;

@end

@implementation ProductDetailViewController

-(id)initWithProduct: (ProductGift *)product andMode:(NSString *)mode{
    if (self = [super init]) {
        self.product = product;
        self.mode = mode;
    }
    return self;
}

- (void)initViewStyle {
    self.view.layer.cornerRadius = 4.0f;
    self.view.clipsToBounds = YES;
    self.txtName.layer.cornerRadius = 4.0f;
    self.txtPrice.layer.cornerRadius = 4.0f;
    self.txtQuantity.layer.cornerRadius = 4.0f;
    self.txtDescription.layer.cornerRadius = 4.0f;
    self.txtName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtName.bounds.size.height)];
    self.txtName.leftViewMode = UITextFieldViewModeAlways;
    self.txtName.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtName.bounds.size.height)];
    self.txtName.rightViewMode = UITextFieldViewModeAlways;
    self.txtPrice.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtPrice.bounds.size.height)];
    self.txtPrice.leftViewMode = UITextFieldViewModeAlways;
    self.txtPrice.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtPrice.bounds.size.height)];
    self.txtPrice.rightViewMode = UITextFieldViewModeAlways;
    self.txtQuantity.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtQuantity.bounds.size.height)];
    self.txtQuantity.leftViewMode = UITextFieldViewModeAlways;
    self.txtQuantity.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, self.txtQuantity.bounds.size.height)];
    self.txtQuantity.rightViewMode = UITextFieldViewModeAlways;
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

-(void)loadData {
    if (self.product.imageURLs!=nil && [self.product.imageURLs count] > 0) {
        [self loadImage:self.imageProduct withURL:self.product.imageURLs[0]];
    } else {
        // TODO set default image
    }
    self.txtName.text = self.product.name;
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.txtPrice.text = [currencyFormat stringFromNumber:self.product.price];
    self.txtQuantity.text = [NSString stringWithFormat:@"%ld", self.product.quantity];
    self.txtDescription.text = self.product.productDescription;
}

-(void)updateProductData {
    self.product.name = self.txtName.text;
    self.product.price = [[NSDecimalNumber alloc] initWithString:[self.txtPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""]];
    self.product.quantity = [self.txtQuantity.text intValue];
    self.product.productDescription = self.txtDescription.text;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewStyle];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onBtnAddGiftClicked:(id)sender {
    [self updateProductData];
    [self.product saveToParse];
    if (self.delegate) {
        [self.delegate productDetailViewController:self didProductGiftAdd:self.product];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
}

@end
