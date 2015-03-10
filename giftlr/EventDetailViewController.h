//
//  EventDetailViewController.h
//  giftlr
//
//  Created by Yingming Chen on 3/8/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventDetailViewController : UIViewController

@property (nonatomic, strong) Event *event;

- (void)setEvent:(Event *)event;

@end
