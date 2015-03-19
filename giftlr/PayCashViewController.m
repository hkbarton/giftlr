//
//  PayCashViewController.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PayCashViewController.h"
#import "User.h"

@interface PayCashViewController ()
- (IBAction)onPayButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation PayCashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.text = self.cashGift.name;
    
    NSNumberFormatter *currencyFormat = [[NSNumberFormatter alloc] init];
    [currencyFormat setNumberStyle: NSNumberFormatterCurrencyStyle];
    self.amountLabel.text = [currencyFormat stringFromNumber:self.cashGift.amount];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPayButton:(id)sender {
    self.cashGift.status = CashGiftTransferred;
    self.cashGift.claimerFacebookUserID = [User currentUser].fbUserId;
    self.cashGift.claimerName = [User currentUser].name;
    [self.cashGift saveToParse];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
