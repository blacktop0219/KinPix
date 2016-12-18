//
//  GroupViewCell.m
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "AlbumPhotoViewCell.h"

@implementation AlbumPhotoViewCell

@synthesize ivImage;

- (void)awakeFromNib
{
    [AppDelegate processPhotoView:ivImage];
    [self.viewMain removeFromSuperview];
    [self addSubview:self.viewMain];
}

@end
