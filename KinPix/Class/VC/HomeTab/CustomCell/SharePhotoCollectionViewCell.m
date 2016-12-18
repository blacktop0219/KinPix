//
//  SharePhotoCollectionViewCell.m
//  Zinger
//
//  Created by QingHou on 12/1/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SharePhotoCollectionViewCell.h"

@implementation SharePhotoCollectionViewCell

@synthesize viewBorder, imgView;
@synthesize lblNew;

- (void)awakeFromNib
{
    [AppDelegate processFeedView:viewBorder feedimage:imgView];
    [AppDelegate processNewLabel:lblNew];
}

@end
