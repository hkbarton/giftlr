//
//  UserProfileViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/27/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "UserProfileViewController.h"
#import "SettingMenuHeaderView.h"
#import "UIColor+giftlr.h"
#import "ProductGift.h"
#import "EventProductGiftCell.h"
#import "SideViewTransition.h"

@interface UserProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *productGiftList;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventProductGiftCell" bundle:nil] forCellReuseIdentifier:@"EventProductGiftCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 108;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)];
    self.tableView.backgroundColor = [UIColor lightGreyBackgroundColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Left-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    
    
    // load data
    self.productGiftList = [NSMutableArray array];
    [ProductGift loadProductGifts:^(NSArray *productGifts, NSError *error) {
        if (!error) {
            [self.productGiftList addObjectsFromArray:productGifts];
            [self.tableView reloadData];
        }
    }];
    
    
//    self.addGiftActionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                          delegate:self
//                                                 cancelButtonTitle:@"Cancel"
//                                            destructiveButtonTitle:nil
//                                                 otherButtonTitles:@"Choose Gift Online", @"Add Cash Gift", @"Choose from Wishlist", @"Scan Barcode", nil];
    self.title = self.user.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    SettingMenuHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"SettingMenuHeaderView" owner:self options:nil] objectAtIndex:0];
    headerView.user = self.user;
    headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 150);
    self.tableView.tableHeaderView = headerView;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table methods

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
    return self.productGiftList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventProductGiftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventProductGiftCell"];
    
    cell.productGift = self.productGiftList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)onBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
