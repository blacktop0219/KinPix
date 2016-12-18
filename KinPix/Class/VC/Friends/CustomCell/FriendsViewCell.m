//
//  friendsCollectionViewCell.m
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "FriendsViewCell.h"

@implementation FriendsViewCell

@synthesize photoView;

- (void)awakeFromNib
{
    [AppDelegate processUserImage:photoView];
    [self.addView removeFromSuperview];
    [self addSubview:self.addView];
    
    [self.mainView removeFromSuperview];
    [self addSubview:self.mainView];
}


@end
