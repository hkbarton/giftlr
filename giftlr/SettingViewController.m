//
//  SettingViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/15/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingMenuHeaderView.h"
#import "SettingMenuTableViewCell.h"
#import "UIColor+giftlr.h"

NSString *const SettingMenuPayment = @"MENU_PAYMENT";
NSString *const SettingMenuLogout = @"MENU_LOGOUT";
NSString *const SettingMenuWishlist = @"MENU_WISHLIST";
NSString *const SettingMenuContacts = @"MENU_CONTACTS";

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tabbar;

@property (nonatomic, strong) NSArray *menuData;

- (IBAction)onCloseClicked:(id)sender;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabbar.backgroundColor = [UIColor redPinkColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"SettingMenuTableViewCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 57;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.menuData = [NSArray arrayWithObjects:
                     [NSDictionary dictionaryWithObjectsAndKeys:@"payment", @"icon", @"Payment Setting", @"menuDes", SettingMenuPayment, @"menuID", nil],
                     [NSDictionary dictionaryWithObjectsAndKeys:@"wishlist-24", @"icon", @"Wishlist", @"menuDes", SettingMenuWishlist, @"menuID", nil],
                     [NSDictionary dictionaryWithObjectsAndKeys:@"Contacts-25", @"icon", @"Contacts", @"menuDes", SettingMenuContacts, @"menuID", nil],
                     [NSDictionary dictionaryWithObjectsAndKeys:@"logout", @"icon", @"Logout", @"menuDes", SettingMenuLogout, @"menuID", nil],
                     nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    SettingMenuHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"SettingMenuHeaderView" owner:self options:nil] objectAtIndex:0];
    headerView.user = [User currentUser];
    headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 150);
    self.tableView.tableHeaderView = headerView;
}

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
    return self.menuData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingMenuTableViewCell"];
    [cell setMenuItem:self.menuData[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectedMenuID = self.menuData[indexPath.row][@"menuID"];
    if (indexPath.row == 1) {
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate) {
            [self.delegate settingViewController:self didMenuItemSelected:selectedMenuID];
        }
    }];
}

- (IBAction)onCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
