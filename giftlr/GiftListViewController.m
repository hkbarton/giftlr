//
//  GiftListViewController.m
//  giftlr
//
//  Created by Naeim Semsarilar on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "GiftListViewController.h"
#import "EventListViewController.h"
#import "ProductGiftCell.h"
#import "CashGiftCell.h"
#import <Parse/Parse.h>
#import "CashGift.h"
#import "ProductGift.h"

@interface GiftListViewController () <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
- (IBAction)onGiveButton:(id)sender;

@property (strong, nonatomic) NSMutableArray* productGifts;
@property (strong, nonatomic) NSMutableArray* cashGifts;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;


@end

@implementation GiftListViewController

const int PRODUCT_GIFT_SECTION_INDEX = 0;
const int CASH_GIFT_SECTION_INDEX = 1;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductGiftCell" bundle:nil] forCellReuseIdentifier:@"ProductGiftCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CashGiftCell" bundle:nil] forCellReuseIdentifier:@"CashGiftCell"];

    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:1]];
    self.tabBar.delegate = self;
    
    self.productGifts = [NSMutableArray array];
    self.cashGifts = [NSMutableArray array];
    
    PFQuery *productQuery = [PFQuery queryWithClassName:@"ProductGift"];
    [productQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            ProductGift *productGift = [[ProductGift alloc] initWithPFObject:object];
            [self.productGifts addObject:productGift];
        }
        [self refresh];
    }];
    
    PFQuery *cashQuery = [PFQuery queryWithClassName:@"CashGift"];
    [cashQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            CashGift *cashGift = [[CashGift alloc] initWithPFObject:object];
            [self.cashGifts addObject:cashGift];
        }
        [self refresh];
    }];
    
}

- (void) refresh {
    if (self.productGifts == 0 && self.cashGifts == 0) {
        self.emptyView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
    }

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onGiveButton:(id)sender {
    EventListViewController *vc = [[EventListViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
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
        CashGiftCell *cashGiftCell = (CashGiftCell *) cell;
        [cashGiftCell initWithCashGift:self.cashGifts[indexPath.row]];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == PRODUCT_GIFT_SECTION_INDEX) {
        return @"Product Gifts";
    } else if (section == CASH_GIFT_SECTION_INDEX) {
        return @"Cash Gifts";
    }
    return @"";
}

#pragma mark - Tab Bar methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:@"Events"]) {
        EventListViewController *vc = [[EventListViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([item.title isEqualToString:@"Gifts"]) {
    } else if ([item.title isEqualToString:@"Search"]) {
        EventListViewController *vc = [[EventListViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    } else if ([item.title isEqualToString:@"Logout"]) {
    } else {
        
    }
}

@end
