//
//  AddCashGiftViewController.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "AddCashGiftViewController.h"
#import "CashGift.h"
#import "UIColor+giftlr.h"


@interface AddCashGiftViewController ()
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIView *containerDetail;
- (IBAction)onAddButton:(id)sender;
- (IBAction)onCancelButton:(id)sender;

@end

@implementation AddCashGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.containerDetail.backgroundColor = [UIColor lightGreyBackgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAddButton:(id)sender {
    CashGift *cashGift = [[CashGift alloc]init];
    
    cashGift.name = self.nameTextField.text;
    cashGift.amount = [[NSDecimalNumber alloc] initWithString:self.priceTextField.text];
    cashGift.hostEvent = self.event;
    
    [cashGift saveToParse];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
