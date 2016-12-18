//
//  GroupViewCell.m
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "GroupViewCell.h"

@implementation GroupViewCell

- (void)awakeFromNib
{
    [self.addView removeFromSuperview];
    [self addSubview:self.addView];
    
    [self.mainView removeFromSuperview];
    [self addSubview:self.mainView];
}

@end
