//
//  PSSectionHeaderView.m
//  giftlr
//
//  Created by Ke Huang on 3/18/15.
//  Copyright (c) 2015 kenayi. All rights reserved.
//

#import "PSSectionHeaderView.h"

@interface PSSectionHeaderView()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;

@end

@implementation PSSectionHeaderView

-(void)setCreditCardHeader {
    self.labelTitle.text = @"Your Credit Cards";
    self.labelDescription.text = @"(Use for giving money to your friends)";
}

-(void)setBankAccountHeader {
    self.labelTitle.text = @"Your Bank Accounts";
    self.labelDescription.text = @"(Use for receiving money from your friends)";
}

@end
