//
//  SearchViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SearchViewController.h"
#import "UIColor+giftlr.h"
#import "SVProgressHUD.h"
#import "Event.h"
#import "ProductGift.h"
#import "User.h"
#import "CashGift.h"
#import "EventViewCell.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintOfSearchbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlaceholder;

@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) NSMutableArray *productGifts;
@property (nonatomic, strong) NSMutableArray *cashGifts;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSMutableArray *sectionIDs;

@end

@implementation SearchViewController

NSString *const SECTION_ID_EVENT = @"section-event";
NSString *const SECTION_ID_GIFT = @"section-gift";
NSString *const SECTION_ID_CONTACT = @"section-cantact";

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
    self.searchBar.delegate = self;
    // table view
    [self.tableView registerNib:[UINib nibWithNibName:@"EventViewCell" bundle:nil] forCellReuseIdentifier:@"EventViewCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor lightGreyBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    // init view
    self.tableView.hidden = YES;
    self.placeholderView.hidden = NO;
    self.imagePlaceholder.image = [UIImage imageNamed:@"search-placeholder"];
    // init data
    self.sectionIDs = [NSMutableArray array];
    self.events = [NSMutableArray array];
    self.productGifts = [NSMutableArray array];
    self.cashGifts = [NSMutableArray array];
    self.contacts = [NSMutableArray array];
    self.data = [NSDictionary dictionaryWithObjectsAndKeys:
                 self.events, SECTION_ID_EVENT,
                 [NSArray arrayWithObjects:self.productGifts, self.cashGifts, nil], SECTION_ID_GIFT,
                 self.contacts, SECTION_ID_CONTACT, nil];
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

- (NSInteger)getSectionCount {
    [self.sectionIDs removeAllObjects];
    if (self.events.count > 0) {
        [self.sectionIDs addObject:SECTION_ID_EVENT];
    }
    if (self.productGifts.count > 0 || self.cashGifts.count > 0) {
        [self.sectionIDs addObject:SECTION_ID_GIFT];
    }
    if (self.contacts.count > 0) {
        [self.sectionIDs addObject:SECTION_ID_CONTACT];
    }
    return self.sectionIDs.count;
}

- (NSString *)getSectionID:(NSInteger)sectionIndex {
    return self.sectionIDs[sectionIndex];
}

- (NSInteger)getSectionIndexByID:(NSString *)sectionID {
    for(int i=0;i<self.sectionIDs.count;i++) {
        if ([self.sectionIDs[i] isEqualToString:sectionID]) {
            return i;
        }
    }
    return -1;
}

- (NSArray *)getDataOfSection:(NSInteger)sectionIndex {
    return [self.data objectForKey:[self getSectionID:sectionIndex]];
}

- (NSInteger)getRowCountOfSection:(NSInteger)sectionIndex {
    NSString *sectionID = [self getSectionID:sectionIndex];
    NSArray *sectionData = [self getDataOfSection:sectionIndex];
    if ([sectionID isEqualToString:SECTION_ID_GIFT]) {
        return self.productGifts.count + self.cashGifts.count;
    } else {
        return sectionData.count;
    }
}

- (NSString *)getSectionTitle:(NSInteger)sectionIndex {
    NSString *sectionID = [self getSectionID:sectionIndex];
    NSString *sectionTitle = @"";
    if ([sectionID isEqualToString:SECTION_ID_EVENT]) {
        sectionTitle = @"EVENTS";
    } else if ([sectionID isEqualToString:SECTION_ID_GIFT]) {
        sectionTitle = @"GIFTS";
    } else if ([sectionID isEqualToString:SECTION_ID_CONTACT]) {
        sectionTitle = @"CONTACTS";
    }
    return sectionTitle;
}

- (CGFloat)getRowHeightOfSection:(NSInteger)sectionIndex {
    NSString *sectionID = [self getSectionID:sectionIndex];
    if ([sectionID isEqualToString:SECTION_ID_EVENT]) {
        return 266;
    } else if ([sectionID isEqualToString:SECTION_ID_GIFT]) {

    } else if ([sectionID isEqualToString:SECTION_ID_CONTACT]) {

    }
    return 0;
}

- (void)loadTableBySectionID:(NSString *)sectionID {
    if ([self getSectionCount]==0) {
        [SVProgressHUD showInfoWithStatus:@"Can't find anything."];
        return;
    }
    [SVProgressHUD dismiss];
    if (self.tableView.hidden) {
        [self.tableView reloadData];
        self.tableView.alpha = 0;
        self.tableView.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.placeholderView.alpha = 0;
        } completion:^(BOOL finished) {
            self.placeholderView.hidden = YES;
        }];
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.alpha = 1;
        } completion:nil];
    } else {
        [self.tableView reloadData];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self getSectionIndexByID:sectionID]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)searchAndLoad {
    NSString *keyword = self.searchBar.text;
    [Event searchEventsByKeyword:keyword withCompletion:^(NSArray *events) {
        [self.events addObjectsFromArray:events];
        [self loadTableBySectionID:SECTION_ID_EVENT];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.events removeAllObjects];
    [self.productGifts removeAllObjects];
    [self.cashGifts removeAllObjects];
    [self.contacts removeAllObjects];
    [searchBar resignFirstResponder];
    [SVProgressHUD show];
    if (!self.tableView.hidden) {
        [self.tableView reloadData];
    }
    [self searchAndLoad];
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
    return [self getSectionCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self getRowHeightOfSection:indexPath.section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getRowCountOfSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self getSectionTitle:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionID = [self getSectionID:indexPath.section];
    NSArray *data = [self getDataOfSection:indexPath.section];
    if ([sectionID isEqualToString:SECTION_ID_EVENT]) {
        EventViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventViewCell"];
        cell.event = data[indexPath.row];
        [cell zoomEventProfilePic:YES];
        return cell;
    } else if ([sectionID isEqualToString:SECTION_ID_GIFT]) {
        
    }else if ([sectionID isEqualToString:SECTION_ID_CONTACT]) {
        
    }
    return nil;
}

#pragma mark Gesture

- (IBAction)onPlaceholderViewClicked:(id)sender {
    [self.searchBar resignFirstResponder];
}

@end
