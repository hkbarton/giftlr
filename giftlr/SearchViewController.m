//
//  SearchViewController.m
//  giftlr
//
//  Created by Ke Huang on 3/22/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "SearchViewController.h"
#import "UIColor+giftlr.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintOfSearchbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *placeholderView;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlaceholder;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // layout search bar
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.topConstraintOfSearchbar.constant = statusBarHeight;
    [self.searchBar setNeedsUpdateConstraints];
    self.searchBar.tintColor = [UIColor whiteColor];
    for (UIView *subView in [[[self.searchBar subviews] objectAtIndex:0] subviews]) {
        if ([subView isKindOfClass:[UITextField class]]){
            subView.layer.borderColor = [[UIColor lightGrayBorderColor] CGColor];
            subView.layer.borderWidth = 1;
            subView.layer.cornerRadius = 3.0f;
            break;
        }
    }
    // init view
    self.tableView.hidden = YES;
    self.placeholderView.hidden = NO;
    self.imagePlaceholder.image = [UIImage imageNamed:@"search-placeholder"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
