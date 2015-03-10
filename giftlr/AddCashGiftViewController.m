//
//  AddCashGiftViewController.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "AddCashGiftViewController.h"

@interface AddCashGiftViewController ()
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
- (IBAction)onAddButton:(id)sender;

@end

@implementation AddCashGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onAddButton:(id)sender {
}
@end
