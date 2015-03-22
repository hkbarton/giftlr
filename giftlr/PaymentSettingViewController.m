//
//  PaymentSettingViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/16/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PaymentSettingViewController.h"
#import "PaymentInfo.h"
#import "User.h"
#import "PSSectionHeaderView.h"
#import "PSTableViewCell.h"
#import "PSCreationTableViewCell.h"

@interface PaymentSettingViewController () <UITableViewDataSource, UITableViewDelegate, PSCreationTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *creditCards;
@property (nonatomic, strong) NSMutableArray *bankAccounts;

- (IBAction)onCloseButtonClicked:(id)sender;

@end

@implementation PaymentSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    // table view
    [self.tableView registerNib:[UINib nibWithNibName:@"PSTableViewCell" bundle:nil] forCellReuseIdentifier:@"PSTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PSCreationTableViewCell" bundle:nil] forCellReuseIdentifier:@"PSCreationTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 15)];
    // load data
    self.creditCards = [NSMutableArray array];
    self.bankAccounts = [NSMutableArray array];
    [PaymentInfo loadCreditCardsByUser:[User currentUser] withCallback:^(NSArray *pamentInfos, NSError *error) {
        if (!error) {
            [self.creditCards addObjectsFromArray:pamentInfos];
            [self.tableView reloadData];
        }
    }];
    [PaymentInfo loadBankInfosByUser:[User currentUser] withCallback:^(NSArray *pamentInfos, NSError *error) {
        if (!error) {
            [self.bankAccounts addObjectsFromArray:pamentInfos];
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.view.layer.mask = maskLayer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onCloseButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Table View

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.creditCards.count + 1;
    } else if (section == 1) {
        return self.bankAccounts.count + 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section < 2 ? 47 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section < 2) {
        PSSectionHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"PSSectionHeaderView" owner:self options:nil] objectAtIndex:0];
        if (section == 0) {
            [view setCreditCardHeader];
        } else {
            [view setBankAccountHeader];
        }
        return view;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 0 && indexPath.row < self.creditCards.count) || (indexPath.section==1 && indexPath.row < self.bankAccounts.count)) {
        PSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSTableViewCell"];
        cell.paymentInfo = indexPath.section==0 ? self.creditCards[indexPath.row]:self.bankAccounts[indexPath.row];
        return cell;
    } else {
        PSCreationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PSCreationTableViewCell"];
        cell.creationType = indexPath.section;
        cell.delegate = self;
        return cell;
    }
}

-(void)psCreationTableViewCell:(PSCreationTableViewCell *)psCreationTableViewCell didPaymentInfoCreate:(PaymentInfo *)payementInfo {
    if (payementInfo.isBankAccount) {
        [self.bankAccounts addObject:payementInfo];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.creditCards addObject:payementInfo];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
