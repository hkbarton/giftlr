//
//  GiftListViewController.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "GiftListViewController.h"
#import "ProductGiftCell.h"
#import "CashGiftCell.h"

@interface GiftListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
- (IBAction)onGiveButton:(id)sender;

@property (strong, nonatomic) NSArray* productGifts;
@property (strong, nonatomic) NSArray* cashGifts;


@end

@implementation GiftListViewController

const int PRODUCT_GIFT_SECTION_INDEX = 0;
const int CASH_GIFT_SECTION_INDEX = 1;

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.productGifts == 0 && self.cashGifts == 0) {
        self.emptyView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductGiftCell" bundle:nil] forCellReuseIdentifier:@"ProductGiftCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CashGiftCell" bundle:nil] forCellReuseIdentifier:@"CashGiftCell"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onGiveButton:(id)sender {
}

#pragma mark - Table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == PRODUCT_GIFT_SECTION_INDEX) {
        return self.productGifts.count;
    } else if (section == CASH_GIFT_SECTION_INDEX) {
        return self.cashGifts.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == PRODUCT_GIFT_SECTION_INDEX) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ProductGiftCell"];
        ProductGiftCell *productGiftCell = (ProductGiftCell *) cell;
        [productGiftCell initWithProductGift:self.productGifts[indexPath.row]];
    } else if (indexPath.section == CASH_GIFT_SECTION_INDEX) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CashGiftCell"];
    }
    
    return cell;
}
@end
