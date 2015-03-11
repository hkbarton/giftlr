//
//  EventDetailViewController.m
//  giftlr
//
//  Created by Yingming Chen on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventDetailViewCell.h"
#import "EventDescriptionCell.h"
#import "Event.h"
#import "GiftViewCell.h"
#import "ProductSearchViewController.h"
#import "AddCashGiftViewController.h"

@interface EventDetailViewController () <UITableViewDataSource, UITableViewDelegate, ProductSearchViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *addGiftView;
@property (weak, nonatomic) IBOutlet UILabel *addGiftLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *joinEventControl;
- (IBAction)onAddGiftsClicked:(UITapGestureRecognizer *)sender;

@property (strong, nonatomic) NSArray *gifts;
- (IBAction)onAddCashGiftButton:(id)sender;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventDescriptionCell" bundle:nil] forCellReuseIdentifier:@"EventDescriptionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventDetailViewCell" bundle:nil] forCellReuseIdentifier:@"EventDetailViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GiftViewCell" bundle:nil] forCellReuseIdentifier:@"GiftViewCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Left-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    // hot pink #ff69b4
    UIColor *hotPink = [UIColor  colorWithRed:255.0f/255.0f green:105.0f/255.0f blue:180.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = hotPink;
    
    self.addGiftLabel.textColor = hotPink;
    self.addGiftView.layer.cornerRadius = 3;
    self.addGiftView.clipsToBounds = YES;
    self.addGiftView.layer.borderColor = hotPink.CGColor;
    self.addGiftView.layer.borderWidth = 1.5;
    self.addGiftView.backgroundColor = [UIColor  colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f];
    
    self.joinEventControl.tintColor = hotPink;
    self.joinEventControl.backgroundColor = [UIColor  colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f];
    if (self.event.isHostEvent == YES) {
        self.addGiftView.hidden = NO;
        self.joinEventControl.hidden = YES;
    } else {
        self.addGiftView.hidden = YES;
        self.joinEventControl.hidden = NO;
    }

    switch (self.event.eventType) {
        case EventTypeAttending:
            self.joinEventControl.selectedSegmentIndex = 0;
            break;
        case EventTypeMaybe:
            self.joinEventControl.selectedSegmentIndex = 1;
            break;
        case EventTypeDeclined:
            self.joinEventControl.selectedSegmentIndex = 2;
            break;
        case EventTypeNotReplied:
            self.joinEventControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            break;
        default:
            self.joinEventControl.selectedSegmentIndex = UISegmentedControlNoSegment;
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0) {
//        return 400;
//    } else {
//        return 100.0;
//    }
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // TODO: integration with gifts
    return 2 + 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        EventDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailViewCell"];
        cell.event = self.event;
        return cell;
    }
    
    if (indexPath.row == 1) {
        EventDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDescriptionCell"];
        if (self.event.eventDescription) {
            cell.eventDescriptionLabel.text = self.event.eventDescription;
        } else {
            cell.eventDescriptionLabel.text = self.event.name;
        }
        [cell.eventDescriptionLabel sizeToFit];
        return cell;
    }
    
    GiftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GiftViewCell"];
    cell.event = self.event;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - setters

- (void)setEvent:(Event *)event {
    _event = event;
    
    self.title = event.name;
}

#pragma mark - Navigation

- (void) onBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onAddGiftsClicked:(UITapGestureRecognizer *)sender {
    ProductSearchViewController *psvc = [[ProductSearchViewController alloc] initWithHostEvent:self.event];
    psvc.delegate = self;
    UINavigationController *psnvc = [[UINavigationController alloc] initWithRootViewController:psvc];
    [self presentViewController:psnvc animated:YES completion:nil];
}

- (IBAction)onAddCashGiftButton:(id)sender {
    AddCashGiftViewController *vc = [[AddCashGiftViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Delegate of other view controllers

-(void)productSearchViewController:(ProductSearchViewController *)productSearchViewController didProductGiftAdd:(ProductGift *)productGift {
    
}

@end
