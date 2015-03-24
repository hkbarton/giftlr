//
//  CCPickerViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/23/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "CCPickerViewController.h"
#import "PSTableViewCell.h"

@interface CCPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *creditCards;

- (IBAction)onBtnCloseClicked:(id)sender;

@end

@implementation CCPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 4.0f;
    self.view.clipsToBounds = YES;
    // table view
    [self.tableView registerNib:[UINib nibWithNibName:@"PSTableViewCell" bundle:nil] forCellReuseIdentifier:@"PSTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.creditCards = [NSMutableArray array];
    [PaymentInfo loadCreditCardsByUser:[User currentUser] withCallback:^(NSArray *pamentInfos, NSError *error) {
        if (!error) {
            [self.creditCards addObjectsFromArray:pamentInfos];
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark table view

// fix separator inset bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.creditCards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSTableViewCell"];
    cell.paymentInfo = self.creditCards[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PaymentInfo *selectedPayment = self.creditCards[indexPath.row];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate CCPickerViewController:self didPickCreditCard:selectedPayment];
        }
    }];
}

- (IBAction)onBtnCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
