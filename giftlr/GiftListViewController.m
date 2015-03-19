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
#import "UIColor+giftlr.h"
#import "User.h"
#import "EventDetailViewController.h"

@interface GiftListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
- (IBAction)onGiveButton:(id)sender;

@property (strong, nonatomic) NSMutableArray* productGifts;
@property (strong, nonatomic) NSMutableArray* cashGifts;
@property (nonatomic, assign) BOOL isMyGivenGifts;
@property (weak, nonatomic) IBOutlet UIButton *givenButton;
@property (weak, nonatomic) IBOutlet UIButton *receivedButton;
@property (weak, nonatomic) IBOutlet UIButton *giveButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *bottomBorder;
@property (nonatomic, weak) UIImageView *navBarHairlineImageView;

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

    self.productGifts = [NSMutableArray array];
    self.cashGifts = [NSMutableArray array];


    self.isMyGivenGifts = YES;

    [self updateTableData];
    [self updateButtons];
    
    self.tableView.estimatedRowHeight = 200;
    
    self.title = @"Gifts";
    
    self.bottomBorder.backgroundColor = [UIColor redPinkColor];
    
    //    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    //    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    // Hide the border line of navigation bar: http://stackoverflow.com/questions/19226965/how-to-hide-ios7-uinavigationbar-1px-bottom-line
    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    self.navBarHairlineImageView.hidden = YES;

}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)updateTableData {
    [self.productGifts removeAllObjects];
    [self.cashGifts removeAllObjects];

    NSString *currentFacebookUserID = [User currentUser].fbUserId;
    PFQuery *productQuery = [PFQuery queryWithClassName:@"ProductGift"];
    if (self.isMyGivenGifts) {
        [productQuery whereKey:@"claimerFacebookUserID" equalTo:currentFacebookUserID];
    } else {
        [productQuery whereKey:@"hostFacebookUserID" equalTo:currentFacebookUserID];
    }
    [productQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            ProductGift *productGift = [[ProductGift alloc] initWithPFObject:object];
            [self.productGifts addObject:productGift];
        }
        [self refresh];
    }];
    
    PFQuery *cashQuery = [PFQuery queryWithClassName:@"CashGift"];
    if (self.isMyGivenGifts) {
        [cashQuery whereKey:@"claimerFacebookUserID" equalTo:currentFacebookUserID];
    } else {
        [cashQuery whereKey:@"hostFacebookUserID" equalTo:currentFacebookUserID];
    }
    [cashQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            CashGift *cashGift = [[CashGift alloc] initWithPFObject:object];
            [self.cashGifts addObject:cashGift];
        }
        [self refresh];
    }];
}

- (void)updateButtons {
    if (self.isMyGivenGifts) {
        self.givenButton.backgroundColor = [UIColor redPinkColor];
        self.givenButton.tintColor = [UIColor whiteColor];
        self.receivedButton.backgroundColor = [UIColor lightGreyBackgroundColor];
        self.receivedButton.tintColor = [UIColor hotPinkColor];
    } else {
        self.givenButton.backgroundColor = [UIColor lightGreyBackgroundColor];
        self.givenButton.tintColor = [UIColor hotPinkColor];
        self.receivedButton.backgroundColor = [UIColor redPinkColor];
        self.receivedButton.tintColor = [UIColor whiteColor];
    }
}

- (void) refresh {
    if (self.productGifts.count == 0 && self.cashGifts.count == 0) {
        self.emptyView.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.emptyView.hidden = YES;
        self.tableView.hidden = NO;
    }
    
    if (self.emptyView.hidden == NO) {
        if (self.isMyGivenGifts) {
            self.addButton.hidden = YES;
            self.giveButton.hidden = NO;
        } else {
            self.addButton.hidden = NO;
            self.giveButton.hidden = YES;
        }
    }

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onGiveButton:(id)sender {
    [self.delegate goToEventListWithGiftListViewController:self];
}

- (IBAction)onAddButton:(id)sender {
    [self.delegate goToEventListWithGiftListViewController:self];
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
//        cell = [tableView dequeueReusableCellWithIdentifier:@"CashGiftCell"];
//        CashGiftCell *cashGiftCell = (CashGiftCell *) cell;
//        [cashGiftCell initWithCashGift:self.cashGifts[indexPath.row]];

        cell = [tableView dequeueReusableCellWithIdentifier:@"ProductGiftCell"];
        ProductGiftCell *productGiftCell = (ProductGiftCell *) cell;
        [productGiftCell initWithCashGift:self.cashGifts[indexPath.row]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *facebookEventID;
    if (indexPath.section == PRODUCT_GIFT_SECTION_INDEX) {
        facebookEventID = ((ProductGift *) self.productGifts[indexPath.row]).hostEvent.fbEventId;
    } else if (indexPath.section == CASH_GIFT_SECTION_INDEX) {
        facebookEventID = ((CashGift *) self.cashGifts[indexPath.row]).hostEvent.fbEventId;
    }
    
    if (facebookEventID) {
        EventDetailViewController *edvc = [[EventDetailViewController alloc] init];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:edvc];
        
        [Event fetchEventWithFacebookEventID:facebookEventID completion:^(NSArray *events, NSError *error) {
            edvc.event = events[0];
            [self presentViewController:nvc animated:YES completion:^{
            }];
        }];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == PRODUCT_GIFT_SECTION_INDEX) {
        return @"Product Gifts";
    } else if (section == CASH_GIFT_SECTION_INDEX) {
        return @"Cash Gifts";
    }
    return @"";
}
- (IBAction)onGivenButton:(id)sender {
    if (self.isMyGivenGifts == YES) {
        return;
    }
    
    self.isMyGivenGifts = YES;
    [self updateTableData];
    [self updateButtons];
}
- (IBAction)onReceivedButton:(id)sender {
    if (self.isMyGivenGifts == NO) {
        return;
    }
    
    self.isMyGivenGifts = NO;
    [self updateTableData];
    [self updateButtons];
}

@end
