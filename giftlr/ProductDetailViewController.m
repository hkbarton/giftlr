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
#import "UIColor+giftlr.h"
#import "User.h"
#import "ProductHTMLParser.h"

NSString *const ProductDetailViewModeAdd = @"ProductDetailViewModeAdd";
NSString *const ProductDetailViewModeView = @"ProductDetailViewModeView";

@interface ProductDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIView *containerDetail;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelQuantity;
@property (weak, nonatomic) IBOutlet UITextField *txtQuantity;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageProduct;
@property (weak, nonatomic) IBOutlet UIView *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *btnAddGift;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintOfTabbar;

@property (nonatomic, strong) ProductGift *product;
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, assign) CGPoint oriCenterOfView;

- (IBAction)onBtnAddGiftClicked:(id)sender;
- (IBAction)onCloseButtonClicked:(id)sender;
- (IBAction)onMainViewTap:(id)sender;

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
    self.containerDetail.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.tabbar.backgroundColor = [UIColor redPinkColor];
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
    self.heightConstraintOfTabbar.constant = 49;
    self.labelTitle.text = @"Edit Gift";
    // set read only mode
    if ([self.mode isEqualToString:ProductDetailViewModeView]) {
        self.heightConstraintOfTabbar.constant = 0;
        self.btnAddGift.hidden = YES;
        self.labelQuantity.hidden = YES;
        self.txtQuantity.hidden = YES;
        [self.tabbar setNeedsUpdateConstraints];
        self.txtName.enabled = NO;
        self.txtPrice.enabled = NO;
        self.txtQuantity.enabled = NO;
        [self.txtDescription setEditable:NO];
        self.labelTitle.text = [NSString stringWithFormat:@"%@",[ProductHTMLParser getDomainFromURL:[NSURL URLWithString:self.product.productURL]]];
    }
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
    self.txtQuantity.text = @"1";
    self.txtDescription.text = self.product.productDescription;
}

-(void)updateProductData {
    self.product.name = self.txtName.text;
    self.product.price = [[NSDecimalNumber alloc] initWithString:[self.txtPrice.text stringByReplacingOccurrencesOfString:@"$" withString:@""]];
    self.product.productDescription = self.txtDescription.text;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewStyle];
    [self loadData];
    // deal with keyboard
    self.txtName.delegate = self;
    self.txtPrice.delegate = self;
    self.txtQuantity.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    self.oriCenterOfView = self.view.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)findFirstResponderInDetailView {
    UIView *result = nil;
    for (int i=0;i<self.containerDetail.subviews.count;i++) {
        UIView *subView = self.containerDetail.subviews[i];
        if ([subView isFirstResponder]) {
            result = subView;
            break;
        }
    }
    return result;
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIView *curResponder = [self findFirstResponderInDetailView];
    if (curResponder) {
        CGFloat bottomOfCurResponder = curResponder.frame.origin.y + curResponder.frame.size.height + self.containerDetail.frame.origin.y + self.view.frame.origin.y;
        CGFloat topOfKeyboard = [[UIScreen mainScreen] applicationFrame].size.height - kbSize.height;
        if (bottomOfCurResponder > topOfKeyboard) {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.center = CGPointMake(self.oriCenterOfView.x, self.oriCenterOfView.y - bottomOfCurResponder + topOfKeyboard);
            }];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = self.oriCenterOfView;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)onBtnAddGiftClicked:(id)sender {
    NSInteger quatity = [self.txtQuantity.text intValue];
    [self updateProductData];
    NSMutableArray *products = [NSMutableArray array];
    for (int i = 0; i < quatity; i++) {
        ProductGift *clonedProduct = [self.product clone];
        [products addObject:clonedProduct];
        [clonedProduct saveToParse];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate productDetailViewController:self didProductGiftAdd:products];
        }
    }];
}

- (IBAction)onCloseButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onMainViewTap:(id)sender {
    [[self findFirstResponderInDetailView] resignFirstResponder];
}

- (IBAction)onBtnBuyClicked:(id)sender {
    PurchaseViewController *pvc = [[PurchaseViewController alloc] initWithProduct:self.product];
    UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    [self presentViewController:pnvc animated:YES completion:nil];
}

- (IBAction)onBtnClaimClicked:(id)sender {
    self.product.claimerFacebookUserID = [User currentUser].fbUserId;
    self.product.claimerName = [User currentUser].name;
    self.product.status = ProductGiftStatusClaimed;
    [self.product saveToParse];
}

@end
