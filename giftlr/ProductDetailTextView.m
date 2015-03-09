//
//  ProductDetailTextView.m
//  giftlr
//
//  Created by Ke Huang on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ProductDetailTextView.h"

@interface ProductDetailTextView()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtQuantity;
@property (weak, nonatomic) IBOutlet UITextView *txtDescription;

@end

@implementation ProductDetailTextView

- (void)initSubViews {
    UINib *nib = [UINib nibWithNibName:@"ProductDetailTextView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    self.contentView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.contentView];
    // set subview style
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

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubViews];
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

-(void)setProduct:(ProductGift *)product {
    _product = product;
    self.txtName.text = product.name;
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.txtPrice.text = [currencyFormat stringFromNumber:product.price];
    self.txtQuantity.text = [NSString stringWithFormat:@"%ld", product.quantity];
    self.txtDescription.text = @"";
}

@end
