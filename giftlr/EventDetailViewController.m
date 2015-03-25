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
#import "EventProductGiftCell.h"
#import "EventCashGiftCell.h"
#import "EventInviteGuestViewController.h"
#import "ProductSearchViewController.h"
#import "AddCashGiftViewController.h"
#import "ProductDetailViewController.h"
#import "PurchaseViewController.h"
#import "PayCashViewController.h"
#import "ModalViewTransition.h"
#import "UIColor+giftlr.h"
#import "User.h"
#import "Activity.h"
#import "PaymentInfo.h"
#import "PaymentSettingViewController.h"
#import "BottomUpTransition.h"
#import "CCPickerViewController.h"

typedef NS_ENUM(NSInteger, AddGiftActionType) {
    AddGiftActionTypeProduct = 0,
    AddGiftActionTypeCash = 1,
    AddGiftActionTypeCancel = 2
};

@interface EventDetailViewController () <UITableViewDataSource, UITableViewDelegate, ProductSearchViewControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, EventProductGiftCellDelegate, EventCashGiftCellDelegate, EventDetailViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CCPickerViewControllerDelegate, AddCashGiftViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *joinEventControl;
@property (weak, nonatomic) IBOutlet UIView *addGiftControl;

@property (strong, nonatomic) NSArray *gifts;

@property (nonatomic, strong) NSMutableArray *productGiftList;
@property (nonatomic, strong) NSMutableArray *cashGiftList;
@property (nonatomic, strong) EventDetailViewCell *eventDetailCell;
@property (nonatomic, strong) ModalViewTransition *productDetailViewTransition;
@property (nonatomic, strong) ModalViewTransition *addCashGiftViewTransition;

@property (nonatomic, strong) UIActionSheet *addGiftActionSheet;
@property (nonatomic, strong) UIActionSheet *changeEventProfilePicActionSheet;
@property (nonatomic, strong) BottomUpTransition *paymentSettingViewTransition;
@property (nonatomic, strong) BottomUpTransition *ccPickerTransition;
@property (nonatomic, strong) EventCashGiftCell *currentCashGiftCell;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;


@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EventDescriptionCell" bundle:nil] forCellReuseIdentifier:@"EventDescriptionCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventDetailViewCell" bundle:nil] forCellReuseIdentifier:@"EventDetailViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventProductGiftCell" bundle:nil] forCellReuseIdentifier:@"EventProductGiftCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventCashGiftCell" bundle:nil] forCellReuseIdentifier:@"EventCashGiftCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 108;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 0)];
    self.tableView.backgroundColor = [UIColor lightGreyBackgroundColor];
    
    self.addGiftControl.backgroundColor = [UIColor redPinkColorWithAlpha:0.8f];
    self.addGiftControl.hidden = YES;

    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Left-25"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    
    self.joinEventControl.tintColor = [UIColor hotPinkColor];
    self.joinEventControl.backgroundColor = [UIColor  colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.5f];
    if (self.event.isHostEvent == YES) {
        if ([self.event.startTime compare:[NSDate date]] == NSOrderedDescending) {
            self.addGiftControl.hidden = NO;
            UIBarButtonItem *addGuestItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AddUser-26"] style:UIBarButtonItemStylePlain target:self action:@selector(onInviteGuest)];
            
            self.navigationItem.rightBarButtonItems = @[addGuestItem];
        }
        self.joinEventControl.hidden = YES;
    } else {
        self.joinEventControl.hidden = YES;
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
    
    [self setupSwipeGuestures];
    
    // load data
    self.productGiftList = [NSMutableArray array];
    [ProductGift loadProductGiftsByEvent:self.event withCallback:^(NSArray *productGifts, NSError *error) {
        if (!error) {
            [self.productGiftList addObjectsFromArray:productGifts];
            [self.tableView reloadData];
        }
    }];
    self.cashGiftList = [NSMutableArray array];

    [CashGift loadCashGiftsByEvent:self.event withCallback:^(NSArray *cashGifts, NSError *error) {
        if (!error) {
            [self.cashGiftList addObjectsFromArray:cashGifts];
            [self.tableView reloadData];
        }
    }];
    
    self.addGiftActionSheet = [[UIActionSheet alloc] initWithTitle:@"What gift do you want to add?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Product", @"Cash", nil];
    

    self.changeEventProfilePicActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                        delegate:self
                                                               cancelButtonTitle:@"Cancel"
                                                          destructiveButtonTitle:nil
                                                               otherButtonTitles:@"Choose a photo", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - swipe guestures

// Need to allow parent container to handle pan gesture while the table view scroll still working
// See http://stackoverflow.com/questions/17614609/table-view-doesnt-scroll-when-i-use-gesture-recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) setupSwipeGuestures {
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(leftSwipe:)];
    [leftSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    leftSwipeRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:leftSwipeRecognizer];
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(rightSwipe:)];
    [rightSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    rightSwipeRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:rightSwipeRecognizer];
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    //do you right swipe stuff here. Something usually using theindexPath that you get that way
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    //gestureRecognizer
    if (indexPath.row > 1 && indexPath.row < [self.productGiftList count] + 2) {
        EventProductGiftCell *cell = (EventProductGiftCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell showControlView];
    } else if (indexPath.row >= [self.productGiftList count] + 2) {
        EventCashGiftCell *cell = (EventCashGiftCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell showControlView];
    }
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer {
    //do you right swipe stuff here. Something usually using theindexPath that you get that way
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    //gestureRecognizer
    if (indexPath.row > 1 && indexPath.row < [self.productGiftList count] + 2) {
        EventProductGiftCell *cell = (EventProductGiftCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell hideControlView];
    } else if (indexPath.row >= [self.productGiftList count] + 2) {
        EventCashGiftCell *cell = (EventCashGiftCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell hideControlView];
    }
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 400;
    }
    
    return 108;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2 + [self.productGiftList count] + [self.cashGiftList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        EventDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventDetailViewCell"];
        cell.event = self.event;
        cell.delegate = self;
        self.eventDetailCell = cell;
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
    
    // load ProductGift list
    if (indexPath.row > 1 && indexPath.row < [self.productGiftList count] + 2) {
        EventProductGiftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventProductGiftCell"];
        cell.event = self.event;
        cell.delegate = self;
        cell.productGift = self.productGiftList[indexPath.row - 2];
        return cell;
    // load CashGift list
    } else if (indexPath.row >= [self.productGiftList count] + 2) {
        EventCashGiftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCashGiftCell"];
        cell.event = self.event;
        cell.delegate = self;
        cell.cashGift = self.cashGiftList[indexPath.row - 2 - [self.productGiftList count]];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row > 1 && indexPath.row < [self.productGiftList count] + 2) {
        EventProductGiftCell *cell = (EventProductGiftCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.isControlMode) {
            return;
        }
        ProductGift *productGift = self.productGiftList[indexPath.row - 2];
        productGift.hostEvent = self.event;
        ProductDetailViewController *pdvc = [[ProductDetailViewController alloc] initWithProduct:productGift andMode:ProductDetailViewModeView];
        pdvc.modalPresentationStyle = UIModalPresentationCustom;
        self.productDetailViewTransition = [ModalViewTransition newTransitionWithTargetViewController:pdvc];
        pdvc.transitioningDelegate = self.productDetailViewTransition;
        [self presentViewController:pdvc animated:YES completion:nil];
    } else if (indexPath.row >= [self.productGiftList count] + 2) { // cash gift
//        CashGift *cashGift = self.cashGiftList[indexPath.row - 2 - [self.productGiftList count]];
        
//        if (cashGift.status != CashGiftBought && cashGift.status != CashGiftStatusClaimed) {
//            PayCashViewController *vc = [[PayCashViewController alloc] init];
//            vc.cashGift = cashGift;
//            [self presentViewController:vc animated:YES completion:nil];
//        }
    }
}

#pragma mark - setters

- (void)setEvent:(Event *)event {
    _event = event;
    
    self.title = event.name;
}

#pragma mark - action handlers
- (IBAction)onTapAddGift:(UITapGestureRecognizer *)sender {
    [self.addGiftActionSheet showInView:self.view];
}

- (void)onBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onInviteGuest {
    EventInviteGuestViewController *vc = [[EventInviteGuestViewController alloc] init];
    vc.event = self.event;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onAddGift {
    [self.addGiftActionSheet showInView:self.view];
}

- (void)onAddProductGift {
    ProductSearchViewController *psvc = [[ProductSearchViewController alloc] initWithHostEvent:self.event];
    psvc.delegate = self;
    UINavigationController *psnvc = [[UINavigationController alloc] initWithRootViewController:psvc];
    [self presentViewController:psnvc animated:YES completion:nil];
}

- (void)onAddCashGift {
    AddCashGiftViewController *vc = [[AddCashGiftViewController alloc] init];
    vc.event = self.event;
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationCustom;
    self.addCashGiftViewTransition = [ModalViewTransition newTransitionWithTargetViewController:vc andXScale:1 andYScale:0.5];
    vc.transitioningDelegate = self.addCashGiftViewTransition;
    [self presentViewController:vc animated:YES completion:nil];


}

# pragma mark - actionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet == self.addGiftActionSheet) {
        switch (buttonIndex) {
            case AddGiftActionTypeProduct:
                [self onAddProductGift];
                break;
            case AddGiftActionTypeCash:
                [self onAddCashGift];
                break;
            default:
                break;
        }
    } else {
        if (buttonIndex == 0) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
            [self presentViewController:imagePickerController animated:YES completion:^{
            }];
        }
    }
}

#pragma mark - delegate for cells
- (void)eventDetailViewCell:(EventDetailViewCell *)eventDetailViewCell didChangeEventProfileImageTriggered:(BOOL)value {
    [self.changeEventProfilePicActionSheet showInView:self.view];
}

- (void)eventCashGiftCell:(EventCashGiftCell *)eventCashGiftCell didControlClicked:(CashGiftControlType)value {
    CashGift *gift = eventCashGiftCell.cashGift;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:eventCashGiftCell];
    Activity *activity;
    
    self.currentCashGiftCell = eventCashGiftCell;
    self.currentIndexPath = indexPath;
    
    switch (value) {
        case CashGiftControlTypeUnclaim:
            [eventCashGiftCell hideControlView];
            gift.claimerFacebookUserID = @"";
            gift.claimerName = @"";
            gift.status = CashGiftStatusUnclaimed;
            [gift saveToParse];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            break;
        case CashGiftControlTypeClaim:
            [eventCashGiftCell hideControlView];
            gift.claimerFacebookUserID = [User currentUser].fbUserId;
            gift.claimerName = [User currentUser].name;
            gift.claimDate = [NSDate date];
            gift.status = CashGiftStatusClaimed;
            gift.hostEvent = self.event;
            activity = [[Activity alloc] initWithCashGiftClaim:gift];
            [activity saveToParse];
            [gift saveToParse];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case CashGiftControlTypeDelete:
            [self.cashGiftList removeObject:gift];
            [gift deleteFromParse];
            [self.tableView reloadData];
            break;
        case CashGiftControlTypeTransfer:
            [PaymentInfo loadCreditCardsByUser:[User currentUser] withCallback:^(NSArray *pamentInfos, NSError *error) {
                
                if (pamentInfos.count == 0) {
                    PaymentSettingViewController *psvc = [[PaymentSettingViewController alloc] init];
                    self.paymentSettingViewTransition = [BottomUpTransition newTransitionWithTargetViewController:psvc];
                    psvc.transitioningDelegate = self.paymentSettingViewTransition;
                    [self presentViewController:psvc animated:YES completion:nil];

                } else {
                    
                    CCPickerViewController *ccvc = [[CCPickerViewController alloc] init];
                    self.ccPickerTransition = [BottomUpTransition newTransitionWithTargetViewController:ccvc];
                    ccvc.transitioningDelegate = self.ccPickerTransition;
                    [self presentViewController:ccvc animated:YES completion:nil];
                    
                    ccvc.delegate = self;
                    
                }
            }];
            
            break;
    }
}

- (void)eventProductGiftCell:(EventProductGiftCell *)eventProductGiftCell didControlClicked:(ProductGiftControlType)value {
    ProductGift *gift = eventProductGiftCell.productGift;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:eventProductGiftCell];
    Activity *activity;
    
    switch (value) {
        case ProductGiftControlTypeBuy:
            [eventProductGiftCell hideControlView];
            {
                PurchaseViewController *pvc = [[PurchaseViewController alloc] initWithProduct:gift];
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
                [self presentViewController:nvc animated:YES completion:nil];
            }
            break;
        case ProductGiftControlTypeUnclaim:
            [eventProductGiftCell hideControlView];
            gift.claimerFacebookUserID = @"";
            gift.claimerName = @"";
            gift.status = ProductGiftStatusUnclaimed;
            [gift saveToParse];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case ProductGiftControlTypeClaim:
            [eventProductGiftCell hideControlView];
            gift.claimerFacebookUserID = [User currentUser].fbUserId;
            gift.claimerName = [User currentUser].name;
            gift.claimDate = [NSDate date];
            gift.status = ProductGiftStatusClaimed;
            gift.hostEvent = self.event;
            activity = [[Activity alloc] initWithProductGiftClaim:gift];
            [activity saveToParse];
            [gift saveToParse];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case ProductGiftControlTypeDelete:
            [self.productGiftList removeObject:gift];
            [gift deleteFromParse];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    self.eventDetailCell.event.profileImage = image;
    [self.eventDetailCell setEventProfileImage:image];
    
    // Save image to parse
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imageFileName = [NSString stringWithFormat:@"%@-%@.png", self.event.name, [[NSProcessInfo processInfo] globallyUniqueString]];
    PFFile *imageFile = [PFFile fileWithName:imageFileName data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded) {
            NSString *imageUrl = imageFile.url;
            NSLog(@"image url %@", imageUrl);
            self.event.profileUrl = imageFile.url;
            [self.event saveToParse];
        } else {
            NSLog(@"Failed to save image");
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Delegate of other view controllers

- (void)productSearchViewController:(ProductSearchViewController *)productSearchViewController didProductGiftAdd:(NSArray *)products {
    [self.productGiftList addObjectsFromArray:products];
    [self.tableView reloadData];
}

- (void)addCashGiftViewController:(AddCashGiftViewController *)addCashGiftViewController didGiftAdd:(NSArray *)gifts {
    [self.cashGiftList addObjectsFromArray:gifts];
    [self.tableView reloadData];
}


#pragma mark - Delegate for cc piker

- (void)CCPickerViewController:(CCPickerViewController *)ccPickerViewController didPickCreditCard:(PaymentInfo *)paymentInfo {
    
    [self.currentCashGiftCell hideControlView];
    
    CashGift *gift = self.currentCashGiftCell.cashGift;
    
    gift.claimerFacebookUserID = [User currentUser].fbUserId;
    gift.claimerName = [User currentUser].name;
    gift.claimDate = [NSDate date];
    gift.status = CashGiftStatusTransferred;
    gift.hostEvent = self.event;
    //activity = [[Activity alloc] initWithCashGiftTransfer:gift];
    //[activity saveToParse];
    [gift saveToParse];
    [self.tableView reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

@end
