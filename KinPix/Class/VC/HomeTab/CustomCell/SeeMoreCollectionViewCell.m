//
//  SeeMoreCollectionViewCell.m
//  KinPix
//
//  Created by Piao Dev on 25/02/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "SeeMoreCollectionViewCell.h"

@implementation SeeMoreCollectionViewCell

@synthesize viewBackground;

- (void)awakeFromNib
{
    [AppDelegate processFeedView:viewBackground feedimage:nil];
}

@end
