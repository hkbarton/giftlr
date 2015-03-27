//
//  ContactListViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/17/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "ContactListViewController.h"
#import "ContactCell.h"
#import "User.h"
#import "UserProfileViewController.h"
#import "SideViewTransition.h"

@interface ContactListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) SideViewTransition *detailViewTransition;

@end

@implementation ContactListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    self.tableView.rowHeight = 40;

    self.contacts = [[NSArray alloc] init];
    [[User currentUser] getFriendsWithCompletion:^(NSArray *friends, NSError *error) {
        if (!error) {
            self.contacts = friends;
            [self.tableView reloadData];
        }
    }];
    self.title = @"Contacts";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Left-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table methods

// consider add index on the right side: see http://www.appcoda.com/ios-programming-index-list-uitableview/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    cell.contact = self.contacts[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    User *contact = self.contacts[indexPath.row];
    UserProfileViewController *uvc = [[UserProfileViewController alloc] init];
    User *user = [[User alloc] initWithPFUser:contact.pfUser];
    uvc.user = user;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:uvc];
    self.detailViewTransition = [SideViewTransition newTransitionWithTargetViewController:nvc andSideDirection:RightSideDirection];
    self.detailViewTransition.widthPercent = 1.0;
    self.detailViewTransition.AnimationTime = 0.5;
    self.detailViewTransition.addModalBgView = NO;
    self.detailViewTransition.slideFromViewPercent = 0.3;
    nvc.transitioningDelegate = self.detailViewTransition;
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
