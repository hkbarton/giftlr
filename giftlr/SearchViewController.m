//
//  SearchViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SearchViewController.h"
#import "UIColor+giftlr.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintOfSearchbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlaceholder;

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *gifts;
@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // layout search bar
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.topConstraintOfSearchbar.constant = statusBarHeight;
    [self.searchBar setNeedsUpdateConstraints];
    self.searchBar.tintColor = [UIColor redPinkColor];
    for (UIView *subView in [[[self.searchBar subviews] objectAtIndex:0] subviews]) {
        if ([subView isKindOfClass:[UITextField class]]){
            subView.layer.borderColor = [[UIColor lightGrayBorderColor] CGColor];
            subView.layer.borderWidth = 1;
            subView.layer.cornerRadius = 3.0f;
            break;
        }
    }
    // table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // init view
    self.tableView.hidden = YES;
    self.placeholderView.hidden = NO;
    self.imagePlaceholder.image = [UIImage imageNamed:@"search-placeholder"];
}

- (void)viewDidAppear:(BOOL)animated {
   // hack to remove the top border of search bar
    UIView *searchbarTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.searchBar.frame.size.width, 1)];
    searchbarTopBorder.backgroundColor = [UIColor whiteColor];
    [self.searchBar addSubview:searchbarTopBorder];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark Gesture

- (IBAction)onPlaceholderViewClicked:(id)sender {
    [self.searchBar resignFirstResponder];
}

@end
