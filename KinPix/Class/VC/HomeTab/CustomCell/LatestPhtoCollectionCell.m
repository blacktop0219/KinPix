//
//  LatestPhtoCollectionCell.m
//  Zinger
//
//  Created by QingHou on 11/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "LatestPhtoCollectionCell.h"

@implementation LatestPhtoCollectionCell

@synthesize viewBorder, imgView;
@synthesize lblNew;

- (void)awakeFromNib
{
    [AppDelegate processFeedView:viewBorder feedimage:imgView];
    [AppDelegate processNewLabel:lblNew];
}

@end
